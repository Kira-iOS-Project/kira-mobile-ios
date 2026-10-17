import Domain
import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@testable import APIClient

@Suite("Finance API debt detail")
struct FinanceAPIDebtTests {
    @Test("loads engine-calculated detail, installment history, score simulation, and next step")
    func detail() async throws {
        let (api, transport) = KiraAPI.canned(json: debtDetailJSON)
        let detail = try await api.getDebt(id: "debt-1")
        #expect(detail.account.id == "debt-1")
        #expect(detail.account.balance == 500_000)
        #expect(detail.account.dueSoon)
        #expect(detail.account.nextDueAt == CalendarDay(iso: "2026-10-20")?.start)
        #expect(detail.paidInstallments == 5 && detail.totalInstallments == 10)
        #expect(detail.schedule.map(\.status) == [.dueSoon, .upcoming])
        #expect(detail.payments.map(\.timing) == [.onTime, .late])
        #expect(detail.scoreEstimate == DebtScoreEstimate(current: 66, afterPayoff: 71))
        #expect(detail.nextStep == "Bayar sesuai jadwal")
        let request = await transport.request
        #expect(request?.method == .get)
        #expect(request?.path == "/api/debts/debt-1")
    }

    @Test("keeps the detail route's authentication, not-found, and generic failures")
    func detailProblems() async {
        await expectProblems([401, 404]) { _ = try await $0.getDebt(id: "debt-1") }
    }

    @Test("rejects a debt score that is not explicitly simulated")
    func rejectsUnsimulatedScore() async {
        let (api, _) = KiraAPI.canned(json: debtDetailJSON.replacingOccurrences(of: "true", with: "false"))
        await #expect(throws: AppProblem.self) { _ = try await api.getDebt(id: "debt-1") }
    }

    @Test("uses schedule values when the server omits installment counts")
    func fallbackInstallmentCounts() async throws {
        let json =
            debtDetailJSON
            .replacingOccurrences(of: #""installmentsTotal":10,"installmentsRemaining":5,"#, with: "")
            .replacingOccurrences(
                of: #"{"dueDate":"2026-10-20","amount":100000,"status":"dueSoon"}"#,
                with: #"{"dueDate":"2026-10-20","amount":100000,"status":"paid"}"#)
        let (api, _) = KiraAPI.canned(json: json)
        let detail = try await api.getDebt(id: "debt-1")
        #expect(detail.totalInstallments == 2)
        #expect(detail.paidInstallments == 1)
    }

    @Test("rejects a schedule date that is not a calendar day")
    func rejectsInvalidScheduleDate() async {
        let json = debtDetailJSON.replacingOccurrences(of: "2026-10-20", with: "not-a-date")
        let (api, _) = KiraAPI.canned(json: json)
        await #expect(throws: AppProblem.self) { _ = try await api.getDebt(id: "debt-1") }
    }

    @Test("records one idempotent payment then refreshes the debt detail")
    func paymentAndRefresh() async throws {
        let transport = FinanceDebtSequenceTransport([
            .init(status: 200, json: debtPaymentResultJSON), .init(status: 200, json: debtDetailJSON),
        ])
        let api = KiraAPI(
            serverURL: URL(string: "https://api.test") ?? URL(filePath: "/"), transport: transport)
        let paymentId = UUID(uuidString: "e3f5ab14-7ed9-4a9e-9a95-fd98a3eeb541") ?? UUID()
        let detail = try await api.payDebt(
            id: "debt-1", request: DebtPaymentRequest(paymentId: paymentId, amount: 100_000))
        #expect(detail.account.balance == 500_000)
        let requests = await transport.requests
        #expect(requests.count == 2)
        #expect(requests[0].method == .post && requests[0].path == "/api/debts/debt-1/payments")
        let body = try requests[0].decoded(Components.Schemas.RecordDebtPayment.self)
        #expect(body.amount == 100_000)
        #expect(body.paymentId == paymentId.uuidString.lowercased())
        #expect(requests[1].method == .get && requests[1].path == "/api/debts/debt-1")
    }

    @Test("preserves all documented payment problems")
    func paymentProblems() async {
        let request = DebtPaymentRequest(paymentId: UUID(), amount: 1)
        await expectProblems([400, 401, 404, 409, 422]) { _ = try await $0.payDebt(id: "debt-1", request: request) }
    }
}

private let debtDetailJSON =
    #"{"id":"debt-1","name":"Kredivo","kind":"paylater","originalAmount":1000000,"remainingAmount":500000,"monthlyInstallment":100000,"remainingTenorMonths":5,"installmentsTotal":10,"installmentsRemaining":5,"paymentStatus":"on_time","nextInstallment":{"dueDate":"2026-10-20","amount":100000,"status":"dueSoon"},"dueSoon":true,"totalPaid":500000,"scoreEstimate":{"current":66,"afterPayoff":71,"isSimulated":true},"nextStep":"Bayar sesuai jadwal","installmentSchedule":[{"dueDate":"2026-10-20","amount":100000,"status":"dueSoon"},{"dueDate":"2026-11-20","amount":100000,"status":"upcoming"}],"paymentHistory":[{"id":"p1","date":"2026-09-20T00:00:00.000Z","amount":100000,"onTime":true},{"id":"p2","date":"2026-08-20T00:00:00.000Z","amount":100000,"onTime":false}]}"#

private let debtPaymentResultJSON =
    #"{"debtId":"debt-1","monthlyInstalment":100000,"paid":100000,"remaining":500000,"progressPercent":50,"paidOff":false,"nextAccount":null,"scoreEstimate":null}"#

private struct FinanceDebtResponse: Sendable {
    let status: Int
    let json: String
}

private actor FinanceDebtSequenceTransport: ClientTransport {
    private var responses: [FinanceDebtResponse]
    private(set) var requests: [RecordedRequest] = []

    init(_ responses: [FinanceDebtResponse]) {
        self.responses = responses
    }

    func send(
        _ request: HTTPRequest, body: HTTPBody?, baseURL _: URL, operationID _: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let sent: Data? = if let body { try await Data(collecting: body, upTo: 1_000_000) } else { nil }
        requests.append(
            RecordedRequest(method: request.method, path: request.path ?? "", headers: request.headerFields, body: sent)
        )
        guard !responses.isEmpty else { throw AppProblem() }
        let next = responses.removeFirst()
        var fields = HTTPFields()
        fields[.contentType] = next.status >= 400 ? "application/problem+json" : "application/json"
        let response = HTTPResponse(status: .init(code: next.status), headerFields: fields)
        return (response, HTTPBody(Data(next.json.utf8)))
    }
}
