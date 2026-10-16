import APIClient
import Domain

/** Lupa PIN's calls (AKN-02): a sign-in code by email, then its check, which opens a new session. */
package struct LivePinRecoveryService: PinRecoveryService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `POST /auth/code`; the seconds before another code may be sent. */
    package func sendCode(to email: String) async throws -> Int {
        try await api.requestSignInCode(email: email).resendAfterSeconds
    }

    /** `POST /auth/verify`: the new session's tokens. */
    package func verify(code: String, email: String) async throws -> SessionTokens {
        SessionTokens(try await api.verifySignInCode(email: email, code: code).tokens)
    }
}

/** `POST /auth/refresh` as `SessionStore` asks for it. */
package enum SessionRefresh {
    /**
     Renews with `refreshToken`: new tokens, or `.rejected` when the API refuses the token
     (`AUTH_REFRESH_INVALID`), which ends the session. Any other failure is thrown, so an
     unreachable API keeps the session for the next try.
     */
    package static func refresh(_ refreshToken: String, with api: KiraAPI) async throws -> RefreshOutcome {
        do {
            return .renewed(SessionTokens(try await api.refreshSession(refreshToken: refreshToken)))
        } catch let problem as AppProblem where problem.knownCode == .authRefreshInvalid {
            return .rejected
        }
    }
}
