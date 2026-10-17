/** The account rows that Dompet shows, with the two totals kept distinct. */
package struct WalletOverview: Hashable, Sendable {
    package let accounts: [Wallet]

    package init(accounts: [Wallet]) {
        self.accounts = accounts
    }

    /** Money held in bank, e-wallet or cash accounts; liabilities never count as held money. */
    package var heldTotal: Int {
        accounts.filter { !$0.type.isDebt }.reduce(0) { $0 + $1.balance }
    }

    /** The sum of every outstanding liability balance. */
    package var runningDebt: Int {
        accounts.filter { $0.type.isDebt }.reduce(0) { $0 + $1.balance }
    }

    /** The rows grouped as money the person holds. */
    package var wallets: [Wallet] { accounts.filter { !$0.type.isDebt } }

    /** The rows grouped as debt accounts. */
    package var debts: [Wallet] { accounts.filter { $0.type.isDebt } }
}
