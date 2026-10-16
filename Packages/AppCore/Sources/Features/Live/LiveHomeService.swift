import APIClient
import Domain

/**
 Beranda's calls over the API client. Hiding amounts is the account's setting
 (`PATCH /me {hideBalances}`), which the app lock also keeps for the next open.
 */
package struct LiveHomeService: HomeService {
    private let api: KiraAPI
    private let onHideBalances: HideBalancesSync

    /** Calls through `api`; `onHideBalances` hands the setting to the app lock. */
    package init(api: KiraAPI, onHideBalances: @escaping HideBalancesSync) {
        self.api = api
        self.onHideBalances = onHideBalances
    }

    /** `GET /home`. */
    package func home() async throws -> HomeOverview {
        try HomeOverview(try await api.getHome())
    }

    /** `PATCH /me {hideBalances}`. */
    package func setHideBalances(_ isHidden: Bool) async throws {
        _ = try await api.updateMe([.hideBalances(isHidden)])
        await onHideBalances(isHidden)
    }
}

/** Hands "Sembunyikan Saldo saat Membuka" to the app lock once the account saved it. */
package typealias HideBalancesSync = @MainActor @Sendable (Bool) -> Void
