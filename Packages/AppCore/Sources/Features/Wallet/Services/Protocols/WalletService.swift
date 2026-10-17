/** The UNG wallet and debt endpoints; the live implementation uses generated APIClient operations. */
import Domain

package protocol WalletService: Sendable {
    /** `GET /api/wallets`: held-money and debt accounts in one owner-scoped response. */
    func overview() async throws -> WalletOverview

    /**
     `POST /api/wallets`: adds a wallet, or a debt account for a credit card, paylater or pinjol;
     422 when a field is out of range.
     */
    func addWallet(_ draft: WalletDraft) async throws
}
