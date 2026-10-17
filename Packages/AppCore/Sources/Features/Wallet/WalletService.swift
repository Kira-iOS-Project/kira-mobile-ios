/** The UNG wallet and debt endpoints; the live implementation uses generated APIClient operations. */
import Domain

package protocol WalletService: Sendable {
    /** `GET /api/wallets`: held-money and debt accounts in one owner-scoped response. */
    func overview() async throws -> WalletOverview
    /** `POST /api/wallets`: creates a held-money or debt account. */
    func createWallet(type: WalletType, name: String, balance: Int) async throws -> Wallet
}
