import APIClient
import Domain
import Foundation
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

    @Test("offers only the owner's debt accounts to the installment picker")
    func debtAccounts() async throws {
        let wallets =
            #"{"items":[{"id":"wallet-1","name":"BCA","type":"bank","balance":7000000,"createdAt":"2026-10-16T05:00:00.000Z"}],"debts":[{"id":"debt-1","name":"Paylater A","kind":"paylater","originalAmount":6000000,"remainingAmount":4800000,"monthlyInstallment":400000,"remainingTenorMonths":12,"installmentsTotal":18,"installmentsRemaining":12,"paymentStatus":"on_time","nextInstallment":{"dueDate":"2026-10-21","amount":400000,"status":"dueSoon"},"dueSoon":true,"totalPaid":1200000,"scoreEstimate":{"value":66,"isSimulated":true},"nextStep":"Bayar lebih awal"}],"heldTotal":7000000,"totalDebt":4800000}"#
        let (api, transport) = KiraAPI.routed(["GET /api/wallets": ok(wallets)])

        let accounts = try await LiveBillsService(api: api).debtAccounts()

        #expect(accounts == [BillDebtAccount(id: "debt-1", name: "Paylater A")])
        #expect(await transport.routes == ["GET /api/wallets"])
    }

    @Test("forwards a create request and returns the server-saved schedule")
    func creates() async throws {
        let savedBill =
            #"{"id":"bill-1","kind":"bill","name":"Internet Rumah","amount":350000,"category":"bills","nextDueDate":"2026-10-22","repeatInterval":"monthly","installmentsTotal":null,"installmentsRemaining":null,"linkedDebtAccountId":null,"linkedDebtName":null,"dueSoon":false,"paidThisPeriod":false}"#
        let (api, transport) = KiraAPI.routed(["POST /api/bills": ok(savedBill, status: 201)])
        let request = BillCreateRequest(
            name: "Internet Rumah", amount: 350_000, category: .bills,
            nextDueDate: CalendarDay(year: 2026, month: 10, day: 22), repeatInterval: .monthly,
            linkedDebtAccountID: nil,
            clientID: UUID(uuidString: "e3f5ab14-7ed9-4a9e-9a95-fd98a3eeb541") ?? UUID())

        let bill = try await LiveBillsService(api: api).createBill(request)

        #expect(bill.id == "bill-1" && bill.name == "Internet Rumah" && bill.amount == 350_000)
        #expect(await transport.routes == ["POST /api/bills"])
        let sent = try #require(await transport.sent.first)
        #expect(sent.json["name"] == .string("Internet Rumah"))
        #expect(sent.json["amount"] == .number(350_000))
        #expect(sent.json["clientId"] == .string("e3f5ab14-7ed9-4a9e-9a95-fd98a3eeb541"))
    }
}
