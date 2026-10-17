/** The UNG wallet and debt endpoints; the live implementation uses generated APIClient operations. */
import Domain

package protocol WalletService: Sendable {
    /** `GET /api/wallets`: bank accounts, e-wallets and cash. */
    func wallets() async throws -> [Wallet]
    /** `GET /api/debts`: credit card, paylater and pinjol accounts. */
    func debts() async throws -> [Wallet]
}
