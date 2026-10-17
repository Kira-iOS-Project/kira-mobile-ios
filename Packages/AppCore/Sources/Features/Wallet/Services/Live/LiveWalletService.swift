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

    /** A new wallet or debt account. */
    package func addWallet(_ draft: WalletDraft) async throws {
        try await api.createWallet(draft)
    }
}
