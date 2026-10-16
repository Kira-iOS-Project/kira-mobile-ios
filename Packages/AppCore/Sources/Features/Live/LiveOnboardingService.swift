import APIClient
import Domain

/**
 Onboarding's calls over the API client. A verified code starts the session in `SessionStore`
 (the refresh token in the Keychain, the bearer token in memory); screens learn only whether the
 account still needs onboarding.
 */
package struct LiveOnboardingService: OnboardingService {
    private let api: KiraAPI
    private let session: SessionStore
    private let onHideBalances: HideBalancesSync

    /** Calls through `api`, keeping the session in `session`. */
    package init(api: KiraAPI, session: SessionStore, onHideBalances: @escaping HideBalancesSync) {
        self.api = api
        self.session = session
        self.onHideBalances = onHideBalances
    }

    /** `POST /auth/code`. */
    package func requestCode(email: String) async throws -> CodeDelivery {
        let sent = try await api.requestSignInCode(email: email)
        return CodeDelivery(resendAfterSeconds: sent.resendAfterSeconds)
    }

    /** `POST /auth/verify`, then the session starts on this device. */
    package func verify(email: String, code: String) async throws -> SignInResult {
        let signedIn = try await api.verifySignInCode(email: email, code: code)
        try await session.signIn(SessionTokens(signedIn.tokens), email: email)
        return SignInResult(needsOnboarding: signedIn.needsOnboarding)
    }

    /** `PUT /me/consents`. */
    package func saveConsents(_ choices: ConsentChoices) async throws {
        _ = try await api.updateConsents(aiProcessing: choices.aiProcessing, weeklySummary: choices.weeklySummary)
    }

    /** `PATCH /me {focus}`. */
    package func saveFocus(_ focus: Focus) async throws {
        _ = try await api.updateMe([.focus(try Bridge.value(focus))])
    }

    /** `PATCH /me {hideBalances}`. */
    package func saveHideBalances(_ isHidden: Bool) async throws {
        _ = try await api.updateMe([.hideBalances(isHidden)])
        await onHideBalances(isHidden)
    }

    /** `PUT /health-check`. */
    package func submitHealthCheck(_ answers: HealthCheckAnswers) async throws -> ScoreReport {
        try ScoreReport(try await api.saveHealthCheck(try HealthCheckInputDTO(answers)))
    }
}

extension SessionTokens {
    /** The tokens `POST /auth/verify` and `POST /auth/refresh` return. */
    init(_ dto: SessionTokensDTO) {
        self.init(
            accessToken: dto.accessToken, refreshToken: dto.refreshToken,
            accessExpiresInSeconds: dto.accessExpiresInSeconds)
    }
}
