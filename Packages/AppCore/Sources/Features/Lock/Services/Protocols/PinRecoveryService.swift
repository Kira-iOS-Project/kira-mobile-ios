import Foundation

/**
 The two calls of Lupa PIN (AKN-02): the sign-in code by email, then its check, which opens a new
 session. The integrator implements it with the generated client (`requestSignInCode`,
 `verifySignInCode`); errors are thrown as `AppProblem`.
 */
package protocol PinRecoveryService: Sendable {
    /** `POST /auth/code`: sends a code to `email`; returns the seconds before another may be sent. */
    func sendCode(to email: String) async throws -> Int
    /** `POST /auth/verify`: checks `code` for `email` and returns the new session's tokens. */
    func verify(code: String, email: String) async throws -> SessionTokens
}
