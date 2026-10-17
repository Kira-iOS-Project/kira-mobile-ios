/** The UNG wallet and debt endpoints; the live implementation uses generated APIClient operations. */
import Domain

package protocol WalletService: Sendable {
    /** `GET /api/wallets`: held-money and debt accounts in one owner-scoped response. */
    func overview() async throws -> WalletOverview
    /** `POST /api/wallets`: creates a held-money or debt account. */
    func createWallet(type: WalletType, name: String, balance: Int) async throws -> Wallet
    /** `GET /api/debts/{id}`: loads one debt's balance, schedule, payment history, and score estimate. */
    func debt(id: String) async throws -> DebtDetail
    /** `POST /api/debts/{id}/payments`: records the existing idempotent payment operation. */
    func payDebt(id: String, request: DebtPaymentRequest) async throws -> DebtDetail
}
