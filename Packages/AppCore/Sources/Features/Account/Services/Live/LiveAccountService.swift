import APIClient
import Domain
import Foundation

/** Profil, Keamanan and Data & Privasi's calls over the API client. */
package struct LiveAccountService: AccountService {
    private let api: KiraAPI
    private let session: SessionStore
    private let now: @Sendable () -> Date
    private let onHideBalances: HideBalancesSync

    /** Calls through `api`; signing out forgets `session`; `now` names the export's file. */
    package init(
        api: KiraAPI, session: SessionStore, now: @escaping @Sendable () -> Date = Date.init,
        onHideBalances: @escaping HideBalancesSync
    ) {
        self.api = api
        self.session = session
        self.now = now
        self.onHideBalances = onHideBalances
    }

    /** `GET /me`. */
    package func profile() async throws -> AccountProfile {
        try AccountProfile(try await api.getMe())
    }

    /** `PATCH /me {hideBalances}`, which the app lock keeps too. */
    package func setHidesBalances(_ hidden: Bool) async throws -> AccountProfile {
        let profile = try AccountProfile(try await api.updateMe([.hideBalances(hidden)]))
        await onHideBalances(hidden)
        return profile
    }

    /** `GET /me/consents`. */
    package func consents() async throws -> ConsentSettings {
        try ConsentSettings(try await api.getConsents())
    }

    /** `PUT /me/consents`. */
    package func updateConsents(aiProcessing: Bool, weeklySummary: Bool) async throws -> ConsentSettings {
        try ConsentSettings(try await api.updateConsents(aiProcessing: aiProcessing, weeklySummary: weeklySummary))
    }

    /** `GET /me/export`, named `kira-data-YYYY-MM-DD.csv` after today in WIB, as the server names it. */
    package func exportData() async throws -> DataExport {
        let csv = try await api.exportData()
        return DataExport(fileName: "kira-data-\(CalendarDay(now()).iso).csv", csv: csv)
    }

    /** `POST /me/export/email`. */
    package func emailExport() async throws {
        try await api.emailDataExport()
    }

    /** `POST /me/deletion`; the account is gone, so the session on this device goes too. */
    package func deleteAccount(confirmation: String) async throws {
        try await api.deleteAccount(confirmation: confirmation)
        await session.signOut()
    }

    /** `POST /auth/sign-out`, then the tokens go from this device even when the API is out of reach. */
    package func signOut() async throws {
        do {
            try await api.signOut()
        } catch {
            await session.signOut()
            throw error
        }
        await session.signOut()
    }
}
