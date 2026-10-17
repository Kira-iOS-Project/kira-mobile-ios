/** The UNG wallet and debt endpoints; the live implementation uses generated APIClient operations. */
import Domain

/** Where Dompet reads its accounts. */
package protocol WalletService: Sendable {
    /** `GET /api/wallets`: held-money and debt accounts in one owner-scoped response. */
    func overview() async throws -> WalletOverview
}
