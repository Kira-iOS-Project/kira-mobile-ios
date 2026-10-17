import APIClient
import Domain

/** Reads the owner's wallet and debt summaries through the generated finance API. */
package struct LiveWalletService: WalletService {
    private let api: KiraAPI

    /** Uses the same signed-in API client as the other finance screens. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** The owner's held-money accounts. */
    package func wallets() async throws -> [Wallet] {
        try await api.getWallets()
    }

    /** The owner's debt accounts with server-calculated remaining balances and due dates. */
    package func debts() async throws -> [Wallet] {
        try await api.getDebts()
    }
}
