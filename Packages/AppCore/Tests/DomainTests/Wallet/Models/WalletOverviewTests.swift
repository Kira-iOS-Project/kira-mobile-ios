import Testing

@testable import Domain

@Suite("WalletOverview")
struct WalletOverviewTests {
    @Test("held total excludes every debt type and running debt is the remainder sum")
    func totalsAndGroups() {
        let overview = WalletOverview(accounts: [
            Wallet(id: "bank", name: "Bank", type: .bank, balance: 7_000_000),
            Wallet(id: "cash", name: "Tunai", type: .cash, balance: 402_000),
            Wallet(id: "card", name: "Kartu", type: .creditCard, balance: 1_000_000),
            Wallet(id: "paylater", name: "Paylater", type: .paylater, balance: 420_000),
            Wallet(id: "pinjol", name: "Pinjol", type: .onlineLoan, balance: 3_500_000),
        ])
        #expect(overview.heldTotal == 7_402_000)
        #expect(overview.runningDebt == 4_920_000)
        #expect(overview.wallets.map(\.id) == ["bank", "cash"])
        #expect(overview.debts.map(\.id) == ["card", "paylater", "pinjol"])
        #expect(WalletOverview(accounts: []).heldTotal == 0)
        let server = WalletOverview(accounts: overview.accounts, heldTotal: 1, runningDebt: 2)
        #expect(server.heldTotal == 1 && server.runningDebt == 2)
    }
}
