/**
 Lupa PIN's calls with the board's sample behaviour, for previews and for the app until the
 integrator implements `PinRecoveryService` with the generated client: the code "goes out" with a
 60-second resend wait, and any six digits pass.
 */
import Features
import Foundation

nonisolated struct PreviewPinRecoveryService: PinRecoveryService {
    func sendCode(to _: String) throws -> Int { 60 }

    func verify(code _: String, email _: String) throws -> SessionTokens {
        SessionTokens(accessToken: "preview-access", refreshToken: "preview-refresh", accessExpiresInSeconds: 900)
    }
}
