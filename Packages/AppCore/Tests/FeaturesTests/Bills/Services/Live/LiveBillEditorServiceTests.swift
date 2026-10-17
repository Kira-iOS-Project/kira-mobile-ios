import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LiveBillEditorService")
struct LiveBillEditorServiceTests {
    private let draft = BillDraft(
        name: "Internet Rumah", amount: 350_000, category: .other, repeats: .yearly,
        dueOn: CalendarDay(year: 2026, month: 10, day: 22), debtId: "d-1")

    @Test("POST /bills sends the draft's fields with the API's values and returns the id")
    func create() async throws {
        let (api, transport) = KiraAPI.routed(["POST /api/bills": ok(billJSON, status: 201)])
        #expect(try await LiveBillEditorService(api: api).createBill(draft) == "b-1")
        let sent = try #require(await transport.sent.first).json
        #expect(sent["name"] == .string("Internet Rumah") && sent["amount"] == .number(350_000))
        #expect(sent["category"] == .string("other_expense") && sent["repeats"] == .string("yearly"))
        #expect(sent["dueOn"] == .string("2026-10-22") && sent["debtId"] == .string("d-1"))
    }

    @Test("each tile and each Ulangi go out with the API's own values")
    func values() async throws {
        let (api, transport) = KiraAPI.routed(["POST /api/bills": ok(billJSON, status: 201)])
        let service = LiveBillEditorService(api: api)
        for category in BillCategory.allCases {
            var bill = draft
            bill.category = category
            _ = try await service.createBill(bill)
        }
        for repeats in BillRepeat.allCases {
            var bill = draft
            bill.repeats = repeats
            _ = try await service.createBill(bill)
        }
        let sent = await transport.sent.map(\.json)
        let categories: [JSONValue?] = sent.prefix(4).map { $0["category"] }
        let repeats: [JSONValue?] = sent.suffix(3).map { $0["repeats"] }
        #expect(categories == ["bills", "entertainment", "health", "other_expense"].map { .string($0) })
        #expect(repeats == ["once", "monthly", "yearly"].map { .string($0) })
    }

    @Test("PATCH /bills/{id} sends every field; DELETE answers 204")
    func updateAndDelete() async throws {
        let (api, transport) = KiraAPI.routed([
            "PATCH /api/bills/b-1": ok(billJSON),
            "DELETE /api/bills/b-1": RoutedTransport.Reply(status: 204, body: nil),
        ])
        let service = LiveBillEditorService(api: api)
        var plain = draft
        plain.debtId = nil
        #expect(try await service.updateBill(id: "b-1", plain) == "b-1")
        try await service.deleteBill(id: "b-1")
        let sent = await transport.sent
        #expect(sent.map(\.route) == ["PATCH /api/bills/b-1", "DELETE /api/bills/b-1"])
        #expect(sent[0].json["amount"] == .number(350_000) && sent[0].json["debtId"] == nil)
    }

    @Test("a gone bill, a gone debt account, a range, a signed-out session and offline are thrown as their problems")
    func failures() async {
        let (api, _) = KiraAPI.routed([
            "POST /api/bills": problem("BILL_DEBT_NOT_FOUND", status: 404),
            "PATCH /api/bills/gone": problem("BILL_NOT_FOUND", status: 404),
            "DELETE /api/bills/gone": problem("BILL_NOT_FOUND", status: 404),
            "PATCH /api/bills/b-1": problem("VALIDATION_FAILED", status: 422),
            "DELETE /api/bills/b-1": problem("AUTH_UNAUTHENTICATED", status: 401),
        ])
        let service = LiveBillEditorService(api: api)
        let debt = await #expect(throws: AppProblem.self) { try await service.createBill(draft) }
        #expect(debt?.knownCode == .billDebtNotFound)
        let gone = await #expect(throws: AppProblem.self) { try await service.updateBill(id: "gone", draft) }
        #expect(gone?.knownCode == .billNotFound)
        let deleted = await #expect(throws: AppProblem.self) { try await service.deleteBill(id: "gone") }
        #expect(deleted?.knownCode == .billNotFound)
        let range = await #expect(throws: AppProblem.self) { try await service.updateBill(id: "b-1", draft) }
        #expect(range?.knownCode == .validationFailed)
        await #expect(throws: AppProblem.self) { try await service.deleteBill(id: "b-1") }
        let (offline, _) = KiraAPI.routed(["POST /api/bills": problem("ROUTE_NOT_FOUND", status: 500)])
        await #expect(throws: AppProblem.self) { try await LiveBillEditorService(api: offline).createBill(draft) }
    }
}

/** A stored bill as `POST`/`PATCH /bills` answer. */
private let billJSON = #"""
    {"id":"b-1","name":"Internet Rumah","kind":"bill","category":"other_expense","amount":350000,"isEstimate":false,\#
    "repeats":"yearly","dueOn":"2026-10-22","dueDay":22,"nextDueOn":"2026-10-22","daysUntil":5,"debtId":"d-1",\#
    "remainingInstalments":null,"paidThisPeriod":false,"lastPaidOn":null,"createdAt":"2026-10-17T05:00:00.000Z"}
    """#
