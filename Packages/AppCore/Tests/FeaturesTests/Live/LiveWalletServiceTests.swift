import APIClient
import Domain
import Testing

@testable import Features

private let walletListJSON =
    #"{"items":[{"id":"wallet-1","name":"BCA","type":"bank","balance":7000000,"createdAt":"2026-10-16T05:00:00.000Z"}],"debts":[\#(debtSummaryJSON)],"heldTotal":7000000,"totalDebt":4800000}"#

private let debtSummaryJSON =
    #"{"id":"debt-1","name":"Paylater A","kind":"paylater","originalAmount":6000000,"remainingAmount":4800000,"monthlyInstallment":400000,"remainingTenorMonths":12,"installmentsTotal":18,"installmentsRemaining":12,"paymentStatus":"on_time","nextInstallment":{"dueDate":"2026-10-21","amount":400000,"status":"dueSoon"},"dueSoon":true,"totalPaid":1200000,"scoreEstimate":{"value":66,"isSimulated":true},"nextStep":"Bayar lebih awal"}"#

private let walletCreatedJSON =
    #"{"id":"wallet-2","name":"Tunai","type":"cash","balance":200000,"createdAt":"2026-10-16T05:00:00.000Z"}"#
private let debtCreatedJSON =
    #"{"id":"debt-2","name":"Paylater Baru","kind":"paylater","originalAmount":500000,"remainingAmount":500000,"monthlyInstallment":0,"remainingTenorMonths":null,"installmentsTotal":null,"installmentsRemaining":null,"paymentStatus":"on_time","nextInstallment":null,"dueSoon":false,"totalPaid":0,"scoreEstimate":{"value":66,"isSimulated":true},"nextStep":"Catat jadwal cicilan"}"#
@Suite("LiveWalletService")
struct LiveWalletServiceTests {
    @Test("loads held wallets and debt summaries in one owner-scoped response")
    func lists() async throws {
        let (api, transport) = KiraAPI.routed(["GET /api/wallets": ok(walletListJSON)])
        let service = LiveWalletService(api: api)

        let overview = try await service.overview()
        #expect(overview.wallets == [Wallet(id: "wallet-1", name: "BCA", type: .bank, balance: 7_000_000)])
        #expect(
            overview.debts == [
                Wallet(
                    id: "debt-1", name: "Paylater A", type: .paylater, balance: 4_800_000,
                    nextDueAt: CalendarDay(year: 2026, month: 10, day: 21).start, dueSoon: true)
            ])
        #expect(overview.heldTotal == 7_000_000)
        #expect(overview.runningDebt == 4_800_000)
        #expect(await transport.routes == ["GET /api/wallets"])
    }

    @Test("creates a held-money wallet through the shared wallet endpoint")
    func createsWallet() async throws {
        let (api, transport) = KiraAPI.routed([
            "POST /api/wallets": ok(walletCreatedJSON, status: 201)
        ])
        let wallet = try await LiveWalletService(api: api).createWallet(type: .cash, name: "Tunai", balance: 200_000)
        #expect(wallet == Wallet(id: "wallet-2", name: "Tunai", type: .cash, balance: 200_000))
        #expect(await transport.routes == ["POST /api/wallets"])
        let request = try #require(await transport.sent.first)
        #expect(request.json["type"] == .string("cash"))
        #expect(request.json["balance"] == .number(200_000))
    }

    @Test("creates a debt wallet with its outstanding balance through the same endpoint")
    func createsDebtWallet() async throws {
        let (api, transport) = KiraAPI.routed([
            "POST /api/wallets": ok(debtCreatedJSON, status: 201)
        ])
        let debt = try await LiveWalletService(api: api).createWallet(
            type: .paylater, name: "Paylater Baru", balance: 500_000)
        #expect(
            debt
                == Wallet(
                    id: "debt-2", name: "Paylater Baru", type: .paylater, balance: 500_000, dueSoon: false))
        #expect(await transport.routes == ["POST /api/wallets"])
        let request = try #require(await transport.sent.first)
        #expect(request.json["type"] == .string("paylater"))
        #expect(request.json["remainingDebt"] == .number(500_000))
    }
}
