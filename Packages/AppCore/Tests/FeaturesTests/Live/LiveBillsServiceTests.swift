import APIClient
import Domain
import Testing

@testable import Features

@Suite("LiveBillsService")
struct LiveBillsServiceTests {
    @Test("forwards the owner-scoped list request and mapped schedule fields")
    func lists() async throws {
        let json =
            #"{"items":[{"id":"bill-1","kind":"bill","name":"Internet Rumah","amount":350000,"category":"bills","nextDueDate":"2026-10-22","repeatInterval":"monthly","installmentsTotal":null,"installmentsRemaining":null,"linkedDebtAccountId":null,"linkedDebtName":null,"dueSoon":true,"paidThisPeriod":false}]}"#
        let (api, transport) = KiraAPI.routed(["GET /api/bills": ok(json)])

        let bills = try await LiveBillsService(api: api).bills()

        #expect(bills.map(\.id) == ["bill-1"])
        #expect(bills[0].name == "Internet Rumah" && bills[0].isDueSoon)
        #expect(await transport.routes == ["GET /api/bills"])
    }
}
