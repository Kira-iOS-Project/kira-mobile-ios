import APIClient
import Testing

@testable import Features

@Suite("LivePinRecoveryService")
struct LivePinRecoveryServiceTests {
    @Test("Lupa PIN sends a code and trades it for a new session's tokens")
    func recovery() async throws {
        let (api, transport) = KiraAPI.routed([
            "POST /api/auth/code": ok(#"{"expiresInSeconds":600,"resendAfterSeconds":45}"#, status: 202),
            "POST /api/auth/verify": ok("{\(tokensJSON),\"needsOnboarding\":false}"),
        ])
        let service = LivePinRecoveryService(api: api)
        #expect(try await service.sendCode(to: "dinda@email.com") == 45)
        #expect(
            try await service.verify(code: "381449", email: "dinda@email.com")
                == SessionTokens(
                    accessToken: "a-1", refreshToken: "r-1", accessExpiresInSeconds: 900))
        #expect(await transport.sent[1].json == ["email": .string("dinda@email.com"), "code": .string("381449")])
    }

    @Test("a refresh renews the tokens, a refused token ends the session, any other failure is thrown")
    func refresh() async throws {
        let (api, _) = KiraAPI.routed(["POST /api/auth/refresh": ok("{\(tokensJSON)}")])
        #expect(
            try await SessionRefresh.refresh("r-0", with: api)
                == .renewed(
                    SessionTokens(
                        accessToken: "a-1", refreshToken: "r-1", accessExpiresInSeconds: 900)))
        let (refused, _) = KiraAPI.routed(["POST /api/auth/refresh": problem("AUTH_REFRESH_INVALID", status: 401)])
        #expect(try await SessionRefresh.refresh("r-0", with: refused) == .rejected)
        let (failing, _) = KiraAPI.routed(["POST /api/auth/refresh": problem("VALIDATION_FAILED", status: 422)])
        await #expect(throws: AppProblem.self) { try await SessionRefresh.refresh("r-0", with: failing) }
    }
}
