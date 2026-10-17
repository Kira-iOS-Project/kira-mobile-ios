import APIClient
import Domain

/** Reads the owner's wallet and debt summaries through the generated finance API. */
package struct LiveWalletService: WalletService {
    private let api: KiraAPI

    /** Uses the same signed-in API client as the other finance screens. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** The owner's held-money and debt accounts, loaded in one request. */
    package func overview() async throws -> WalletOverview {
        try await api.getWalletOverview()
    }

    /** Adds an account; debt types use the remaining-debt field on the shared wallet endpoint. */
    package func createWallet(type: WalletType, name: String, balance: Int) async throws -> Wallet {
        try await api.createWallet(type: type, name: name, balance: balance)
    }

    /** Loads the schedule and history for one owned debt account. */
    package func debt(id: String) async throws -> DebtDetail {
        try await api.getDebt(id: id)
    }

    /** Records one idempotent payment, then refreshes the server-calculated detail. */
    package func payDebt(id: String, request: DebtPaymentRequest) async throws -> DebtDetail {
        try await api.payDebt(id: id, request: request)
    }
}
