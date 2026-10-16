import Domain

/**
 What the onboarding screens need from the API. The integrator implements it with the generated
 client; every call throws an `AppProblem` when the API refuses. The implementation keeps the
 session's tokens itself (the refresh token in the Keychain, AGENTS.md Rule 13).
 */
package protocol OnboardingService: Sendable {
    /** `POST /auth/code`: emails a six-digit code to `email`, for sign-up and sign-in alike. */
    func requestCode(email: String) async throws -> CodeDelivery

    /** `POST /auth/verify`: signs in with the code and keeps the session's tokens. */
    func verify(email: String, code: String) async throws -> SignInResult

    /** `PUT /me/consents`: saves the purposes the person agreed to. */
    func saveConsents(_ choices: ConsentChoices) async throws

    /** `PATCH /me {focus}`: saves the focus chosen on Pilih Fokus. */
    func saveFocus(_ focus: Focus) async throws

    /** `PATCH /me {hideBalances}`: saves "Sembunyikan Saldo saat Membuka Kira". */
    func saveHideBalances(_ isHidden: Bool) async throws

    /** `PUT /health-check`: saves every answer and returns the first Kira Score. */
    func submitHealthCheck(_ answers: HealthCheckAnswers) async throws -> ScoreReport
}

/**
 Where the app-lock PIN is kept: as a hash in the Keychain on this device, never sent and never
 logged (ONB-14). Agent I0 implements it.
 */
package protocol PinStore: Sendable {
    /** Saves `pin`, replacing any PIN kept before. */
    func save(pin: String) async throws
}
