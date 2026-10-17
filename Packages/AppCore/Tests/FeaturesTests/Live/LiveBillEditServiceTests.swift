import APIClient
import Domain
import Testing

@testable import Features

@Suite("LiveBillEditService")
struct LiveBillEditServiceTests {
    @Test("forwards bill detail and future-schedule updates to Finance")
    func detailAndUpdate() async throws {
        let (api, transport) = KiraAPI.routed([
            "GET /api/bills/bill-1": ok(billJSON),
            "PATCH /api/bills/bill-1": ok(billJSON),
        ])
        let service = LiveBillEditService(api: api)
        let loaded = try await service.bill(id: "bill-1")
        let update = BillScheduleUpdate(
            name: "Internet Baru", amount: 500_000, category: .bills,
            nextDueDate: CalendarDay(year: 2026, month: 11, day: 1), repeatInterval: .monthly)
        let saved = try await service.updateBill(id: "bill-1", update: update)
        #expect(loaded.id == "bill-1" && saved.name == "Internet Rumah")
        #expect(await transport.routes == ["GET /api/bills/bill-1", "PATCH /api/bills/bill-1"])
        #expect(await transport.sent.last?.json["name"] == .string("Internet Baru"))
        #expect(await transport.sent.last?.json["amount"] == .number(500_000))
    }

    @Test("keeps the API problem from a refused update")
    func error() async {
        let (api, _) = KiraAPI.routed(["PATCH /api/bills/bill-1": problem("BILL_NOT_FOUND", status: 404)])
        let service = LiveBillEditService(api: api)
        let update = BillScheduleUpdate(
            name: "Internet", amount: 350_000, category: .bills,
            nextDueDate: CalendarDay(year: 2026, month: 10, day: 22), repeatInterval: .monthly)
        let problem = AppProblem(
            type: AppProblem.typeBase + "BILL_NOT_FOUND", code: "BILL_NOT_FOUND", requestId: "r-1")
        await #expect(throws: problem) {
            try await service.updateBill(id: "bill-1", update: update)
        }
    }

    private var billJSON: String {
        #"{"id":"bill-1","kind":"bill","name":"Internet Rumah","amount":350000,"category":"bills","nextDueDate":"2026-10-22","repeatInterval":"monthly","installmentsTotal":null,"installmentsRemaining":null,"linkedDebtAccountId":null,"linkedDebtName":null,"dueSoon":true,"paidThisPeriod":false}"#
    }
}
