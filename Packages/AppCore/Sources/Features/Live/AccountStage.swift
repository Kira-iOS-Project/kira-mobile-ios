import APIClient

/** Where an account stands in onboarding, read from `GET /me` at launch. */
package enum AccountStage: Equatable, Sendable {
    /** Onboarding is done: the tabs open. */
    case ready(hidesBalances: Bool)
    /** Signed in, but the consents were never given: onboarding resumes at Persetujuan Data. */
    case needsConsent
    /** Consents given, but no health check yet: onboarding resumes at Pilih Fokus. */
    case needsHealthCheck

    /** The stage of the person `me` describes. */
    init(_ account: MeDTO) {
        if !account.consented {
            self = .needsConsent
        } else if !account.healthCheckCompleted {
            self = .needsHealthCheck
        } else {
            self = .ready(hidesBalances: account.hideBalances)
        }
    }

    /** The stage `GET /me` reports, or nil when the API cannot answer now. */
    package static func check(with api: KiraAPI) async -> AccountStage? {
        guard let account = try? await api.getMe() else { return nil }
        return AccountStage(account)
    }
}
