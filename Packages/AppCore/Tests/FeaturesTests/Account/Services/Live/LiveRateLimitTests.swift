import APIClient
import Domain
import Testing

@testable import Features

/** The codes the v1b backend added reach the screens as their own messages, never the generic one. */
@MainActor
@Suite("Live services: verify, export and payment-method refusals")
struct LiveRateLimitTests {
    private let recorder = HideBalancesRecorder()

    @Test("too many codes checked from one address reads as AUTH_VERIFY_RATE_LIMITED, still signed out")
    func verifyRateLimited() async throws {
        let session = newSession()
        let (api, _) = KiraAPI.routed(["POST /api/auth/verify": problem("AUTH_VERIFY_RATE_LIMITED", status: 429)])
        let service = LiveOnboardingService(api: api, session: session, onHideBalances: recorder.sync)
        let thrown = await #expect(throws: AppProblem.self) {
            try await service.verify(email: "dinda@email.com", code: "381449")
        }
        #expect(thrown?.knownCode == .authVerifyRateLimited)
        #expect(thrown?.messageKey == "problem.AUTH_VERIFY_RATE_LIMITED")
        #expect(!session.hasSession)
    }

    @Test("a second export email within ten minutes reads as ACCOUNT_EXPORT_RATE_LIMITED")
    func exportRateLimited() async throws {
        let session = newSession()
        let tokens = SessionTokens(accessToken: "a", refreshToken: "r", accessExpiresInSeconds: 900)
        try await session.signIn(tokens, email: "dinda@email.com")
        let (api, _) = KiraAPI.routed([
            "POST /api/me/export/email": problem("ACCOUNT_EXPORT_RATE_LIMITED", status: 429)
        ])
        let service = LiveAccountService(api: api, session: session, onHideBalances: recorder.sync)
        let thrown = await #expect(throws: AppProblem.self) { try await service.emailExport() }
        #expect(thrown?.knownCode == .accountExportRateLimited)
    }

    @Test("a payment method on a Beasiswa Kira grant reads as SUBSCRIPTION_NOT_PAID")
    func paymentMethodOnGrant() async throws {
        let (api, _) = KiraAPI.routed([
            "PUT /api/subscription/payment-method": problem("SUBSCRIPTION_NOT_PAID", status: 409)
        ])
        let thrown = await #expect(throws: AppProblem.self) {
            try await LivePlansService(api: api).setPaymentMethod(.qris)
        }
        #expect(thrown?.knownCode == .subscriptionNotPaid)
    }
}
