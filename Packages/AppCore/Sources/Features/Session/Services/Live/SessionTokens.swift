import Foundation

/** The tokens of a session, as `POST /auth/verify` and `POST /auth/refresh` return them. */
package struct SessionTokens: Equatable, Sendable {
    /** The bearer token, kept in memory only. */
    package let accessToken: String
    /** The refresh token, kept in the vault. */
    package let refreshToken: String
    /** How long the bearer token lasts from now (900 s). */
    package let accessExpiresInSeconds: Int

    /** Tokens as the API returned them. */
    package init(accessToken: String, refreshToken: String, accessExpiresInSeconds: Int) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessExpiresInSeconds = accessExpiresInSeconds
    }
}

/** What `POST /auth/refresh` answered. A failure to reach the API is thrown instead. */
package enum RefreshOutcome: Equatable, Sendable {
    /** New tokens: the old refresh token is spent. */
    case renewed(SessionTokens)
    /** The API refused the refresh token (`AUTH_REFRESH_INVALID`): the session has ended. */
    case rejected
}
