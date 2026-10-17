/** The account rows that Dompet shows, with the two totals kept distinct. */

/** Dompet's accounts and the server's two totals: money held and debt still owed. */
package struct WalletOverview: Hashable, Sendable {
    /** Every account, held money first, as the API lists them. */
    package let accounts: [Wallet]
    /** Money held in bank, e-wallet or cash accounts; liabilities never count as held money. */
    package let heldTotal: Int
    /** Every outstanding liability balance together. */
    package let runningDebt: Int

    /** The accounts with the totals the API computed (`heldTotal`, `totalDebt` of `GET /wallets`). */
    package init(accounts: [Wallet], heldTotal: Int, runningDebt: Int) {
        self.accounts = accounts
        self.heldTotal = heldTotal
        self.runningDebt = runningDebt
    }

    /** The accounts with both totals summed from their rows, for previews and tests. */
    package init(accounts: [Wallet]) {
        self.init(
            accounts: accounts,
            heldTotal: accounts.filter { !$0.type.isDebt }.reduce(0) { $0 + $1.balance },
            runningDebt: accounts.filter { $0.type.isDebt }.reduce(0) { $0 + $1.balance })
    }

    /** The rows grouped as money the person holds. */
    package var wallets: [Wallet] { accounts.filter { !$0.type.isDebt } }

    /** The rows grouped as debt accounts. */
    package var debts: [Wallet] { accounts.filter { $0.type.isDebt } }
}
