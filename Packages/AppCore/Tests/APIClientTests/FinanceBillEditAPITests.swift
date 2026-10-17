import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

@Suite("Finance API bill edit")
struct FinanceBillEditAPITests {
    @Test("GET returns the selected bill through the owner-scoped path")
    func getBill() async throws {
        let (api, transport) = KiraAPI.canned(json: billJSON)
        let bill = try await api.getBill(id: "bill-1")
        let request = await transport.request
        #expect(bill.id == "bill-1" && bill.name == "Internet Rumah")
        #expect(request?.path == "/api/bills/bill-1")
        #expect(request?.method == .get)
    }

    @Test("PATCH sends only the bill's future schedule and maps the response")
    func updateBill() async throws {
        let (api, transport) = KiraAPI.canned(json: billJSON)
        let update = BillScheduleUpdate(
            name: "Internet Baru", amount: 450_000, category: .household,
            nextDueDate: CalendarDay(year: 2026, month: 11, day: 5), repeatInterval: .yearly)
        let saved = try await api.updateBill(id: "bill-1", update: update)
        let request = await transport.request
        let body = try JSONDecoder().decode(
            Components.Schemas.UpdateBillInput.self, from: request?.body ?? Data())
        #expect(saved.id == "bill-1")
        #expect(request?.method == .patch)
        #expect(request?.path == "/api/bills/bill-1")
        #expect(body.name == "Internet Baru" && body.amount == 450_000)
        #expect(body.category?.rawValue == "household")
        #expect(body.nextDueDate == "2026-11-05" && body.repeatInterval?.rawValue == "yearly")
        #expect(body.linkedDebtAccountId == nil)
    }

    @Test("DELETE cancels the future schedule without touching its history")
    func deleteBill() async throws {
        let (api, transport) = KiraAPI.canned(status: 204)
        try await api.deleteBill(id: "bill-1")
        let request = await transport.request
        #expect(request?.method == .delete && request?.path == "/api/bills/bill-1")
    }

    @Test("maps the documented GET and PATCH failures")
    func failures() async {
        await expectProblems([401, 404, 422]) { _ = try await $0.getBill(id: "bill-1") }
        await expectProblems([401, 404, 422]) {
            _ = try await $0.updateBill(
                id: "bill-1",
                update: BillScheduleUpdate(
                    name: "Internet", amount: 350_000, category: .bills,
                    nextDueDate: CalendarDay(year: 2026, month: 10, day: 22), repeatInterval: .monthly))
        }
        await expectProblems([401, 404, 422]) { try await $0.deleteBill(id: "bill-1") }
    }

    @Test("rejects a category outside the expense contract before sending")
    func invalidCategory() async {
        let (api, transport) = KiraAPI.canned(json: billJSON)
        let update = BillScheduleUpdate(
            name: "Gaji", amount: 1, category: .salary,
            nextDueDate: CalendarDay(year: 2026, month: 10, day: 22), repeatInterval: .monthly)
        await #expect(throws: AppProblem()) { try await api.updateBill(id: "bill-1", update: update) }
        let request = await transport.request
        #expect(request == nil)
    }

    @Test("rejects an invalid server calendar date")
    func invalidDate() async {
        let json = billJSON.replacingOccurrences(of: "2026-10-22", with: "2026-02-30")
        let (api, _) = KiraAPI.canned(json: json)
        await #expect(throws: AppProblem()) { _ = try await api.getBill(id: "bill-1") }
    }

    private var billJSON: String {
        #"{"id":"bill-1","kind":"bill","name":"Internet Rumah","amount":350000,"category":"bills","nextDueDate":"2026-10-22","repeatInterval":"monthly","installmentsTotal":null,"installmentsRemaining":null,"linkedDebtAccountId":null,"linkedDebtName":null,"dueSoon":true,"paidThisPeriod":false}"#
    }
}
