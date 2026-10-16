/** What the sign-in routes answer (ONB-05 to ONB-07b). */

/** A sign-in code is on its way. */
package struct SignInCodeSentDTO: Hashable, Sendable {
    /** How long the code works: 600 seconds. */
    package let expiresInSeconds: Int
    /** When "Kirim Ulang Kode" opens: 60 seconds. */
    package let resendAfterSeconds: Int

    init(_ body: Components.Schemas.CodeRequested) {
        expiresInSeconds = body.expiresInSeconds
        resendAfterSeconds = body.resendAfterSeconds
    }
}

/** A bearer token pair: the access token goes on every request, the refresh token to the Keychain. */
package struct SessionTokensDTO: Hashable, Sendable {
    /** The bearer token for `Authorization`. */
    package let accessToken: String
    /** Trades for a new pair at `POST /api/auth/refresh`. */
    package let refreshToken: String
    /** The access token's lifetime: 900 seconds. */
    package let accessExpiresInSeconds: Int

    init(_ body: Components.Schemas.SessionTokens) {
        accessToken = body.accessToken
        refreshToken = body.refreshToken
        accessExpiresInSeconds = body.accessExpiresInSeconds
    }
}

/** A verified code: the tokens, and whether onboarding still has to run. */
package struct SignedInDTO: Hashable, Sendable {
    /** The new session's tokens. */
    package let tokens: SessionTokensDTO
    /** True until the data consents are given: a new account, or a sign-up left halfway. */
    package let needsOnboarding: Bool

    init(_ body: Components.Schemas.SignedIn) {
        tokens = SessionTokensDTO(body.value1)
        needsOnboarding = body.value2.needsOnboarding
    }
}
