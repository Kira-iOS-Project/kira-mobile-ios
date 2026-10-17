import APIClient
import Domain
import Testing

@testable import Features

private let walletListJSON =
    #"{"items":[{"id":"wallet-1","accountType":"wallet","name":"BCA","type":"bank","balance":70000"#
    + #"00,"createdAt":"2026-10-16T05:00:00.000Z"}],"debts":[\#(debtSummaryJSON)],"heldTotal":710000"#
    + #"0,"totalDebt":4900000}"#

private let debtSummaryJSON =
    #"{"id":"debt-1","accountType":"debt","name":"Paylater A","kind":"paylater","originalAmount":6"#
    + #"000000,"remainingAmount":4800000,"monthlyInstallment":400000,"remainingTenorMonths":12,"inst"#
    + #"allmentsTotal":18,"installmentsRemaining":12,"paymentStatus":"on_time","nextInstallment":{"d"#
    + #"ueDate":"2026-10-21","amount":400000,"status":"dueSoon"},"dueSoon":true,"totalPaid":1200000,"#
    + #""scoreEstimate":{"value":66,"isSimulated":true},"nextStep":"Bayar lebih awal"}"#

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

    @Test("POST /wallets sends a balance for money held, the debt left for a debt account, other for an unnamed kind")
    func adds() async throws {
        let created =
            #"{"accountType":"wallet","id":"6f1c2b9e-0000-4000-8000-000000000002","name":"Dompet Digital 2","#
            + #""type":"e_wallet","balance":0,"#
            + #""createdAt":"2026-10-17T05:00:00.000Z"}"#
        let (api, transport) = KiraAPI.routed(["POST /api/wallets": ok(created, status: 201)])
        let service = LiveWalletService(api: api)
        let types: [WalletType] = [.ewallet, .bank, .cash, .creditCard, .paylater, .onlineLoan, .other, .vehicle]
        for (amount, type) in types.enumerated() {
            try await service.addWallet(WalletDraft(type: type, name: "Dompet", amount: amount))
        }
        let sent = await transport.sent
        let sentTypes = ["e_wallet", "bank", "cash", "credit_card", "paylater", "pinjol", "other", "other"]
        #expect(sent.map { $0.json["type"] } == sentTypes.map(JSONValue.string))
        #expect(sent[0].json["balance"] == .number(0) && sent[3].json["remainingDebt"] == .number(3))
    }

    @Test("a refused wallet is thrown as its problem")
    func addRefused() async {
        let (api, _) = KiraAPI.routed(["POST /api/wallets": problem("VALIDATION_FAILED", status: 422)])
        let error = await #expect(throws: AppProblem.self) {
            try await LiveWalletService(api: api).addWallet(WalletDraft(type: .bank, name: "", amount: 0))
        }
        #expect(error?.code == "VALIDATION_FAILED")
    }
}
