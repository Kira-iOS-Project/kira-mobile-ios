import APIClient
import Domain
import Testing

@testable import Features

private let walletListJSON =
    #"{"items":[{"id":"wallet-1","name":"BCA","type":"bank","balance":7000000,"createdAt":"2026-10-16"#
    + #"T05:00:00.000Z"}],"debts":[\#(debtSummaryJSON)],"heldTotal":7100000,"totalDebt":4900000}"#

private let debtSummaryJSON =
    #"{"id":"debt-1","name":"Paylater A","kind":"paylater","originalAmount":6000000,"remainingAmount""#
    + #":4800000,"monthlyInstallment":400000,"remainingTenorMonths":12,"installmentsTotal":18,"installm"#
    + #"entsRemaining":12,"paymentStatus":"on_time","nextInstallment":{"dueDate":"2026-10-21","amount":"#
    + #"400000,"status":"dueSoon"},"dueSoon":true,"totalPaid":1200000,"scoreEstimate":{"value":66,"isSi"#
    + #"mulated":true},"nextStep":"Bayar lebih awal"}"#

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
                    nextDueAt: CalendarDay(year: 2026, month: 10, day: 21).start)
            ])
        /** The server's totals, not the rows summed (7.000.000 and 4.800.000). */
        #expect(overview.heldTotal == 7_100_000)
        #expect(overview.runningDebt == 4_900_000)
        #expect(await transport.routes == ["GET /api/wallets"])
    }
}
