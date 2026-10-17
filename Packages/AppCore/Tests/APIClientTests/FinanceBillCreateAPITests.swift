import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

@Suite("Finance API bill create")
struct FinanceBillCreateAPITests {
    @Test("posts the request, keeps its idempotency key and maps the saved bill")
    func creates() async throws {
        let clientID = UUID(uuidString: "E3F5AB14-7ED9-4A9E-9A95-FD98A3EEB541") ?? UUID()
        let request = makeRequest(interval: .monthly, linkedDebtAccountID: "debt-1", clientID: clientID)
        let (api, transport) = KiraAPI.canned(status: 201, json: Self.billJSON(kind: "debtInstallment"))

        let bill = try await api.createBill(request)

        #expect(bill.id == "bill-1" && bill.kind == .debtInstallment)
        #expect(bill.linkedDebtAccountID == "debt-1" && bill.name == "Cicilan Paylater")
        let sent = try #require(await transport.request)
        #expect(sent.method == .post && sent.path == "/api/bills")
        let body = try sent.decoded(Components.Schemas.CreateBillInput.self)
        #expect(body.name == "Cicilan Paylater" && body.amount == 125_000)
        #expect(body.category.rawValue == "bills" && body.repeatInterval.rawValue == "monthly")
        #expect(body.nextDueDate == "2026-10-22" && body.linkedDebtAccountId == "debt-1")
        #expect(body.clientId == "e3f5ab14-7ed9-4a9e-9a95-fd98a3eeb541")
    }

    @Test("maps each supported repeat interval to the generated contract")
    func repeatIntervals() throws {
        for interval in BillRepeatInterval.allCases {
            let body = try createBillInput(makeRequest(interval: interval))
            #expect(body.repeatInterval.rawValue == interval.rawValue)
        }
    }

    @Test("rejects an income category that the bill API does not accept")
    func invalidCategory() {
        let request = BillCreateRequest(
            name: "Gaji", amount: 100, category: .salary,
            nextDueDate: CalendarDay(year: 2026, month: 10, day: 22), repeatInterval: .monthly,
            linkedDebtAccountID: nil, clientID: UUID())
        #expect(throws: AppProblem()) { try createBillInput(request) }
    }

    @Test("preserves documented create failures and maps malformed saved dates")
    func failures() async {
        await expectProblems([401, 404, 422]) { _ = try await $0.createBill(makeRequest()) }
        let invalidDate = Self.billJSON(kind: "bill", date: "2026-02-30")
        let (api, _) = KiraAPI.canned(status: 201, json: invalidDate)
        await #expect(throws: AppProblem()) { _ = try await api.createBill(makeRequest()) }
    }

    private func makeRequest(
        interval: BillRepeatInterval = .monthly, linkedDebtAccountID: String? = nil,
        clientID: UUID = UUID()
    ) -> BillCreateRequest {
        BillCreateRequest(
            name: "Cicilan Paylater", amount: 125_000, category: .bills,
            nextDueDate: CalendarDay(year: 2026, month: 10, day: 22), repeatInterval: interval,
            linkedDebtAccountID: linkedDebtAccountID, clientID: clientID)
    }

    private static func billJSON(kind: String, date: String = "2026-10-22") -> String {
        #"{"id":"bill-1","kind":"\#(kind)","name":"Cicilan Paylater","amount":125000,"category":"bills","nextDueDate":"\#(date)","repeatInterval":"monthly","installmentsTotal":null,"installmentsRemaining":null,"linkedDebtAccountId":"debt-1","linkedDebtName":"Paylater","dueSoon":false,"paidThisPeriod":false}"#
    }
}
