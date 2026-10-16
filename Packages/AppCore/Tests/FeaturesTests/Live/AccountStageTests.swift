import APIClient
import Testing

@testable import Features

/**
 Serialized: run in parallel, the four stages' cases raced on the coverage counters and the
 report lost the `.ready` branch now and then, failing the 100% floor with every test passing.
 */
@Suite("AccountStage", .serialized)
struct AccountStageTests {
    @Test(
        "GET /me says where onboarding stands",
        arguments: [
            (false, false, AccountStage.needsConsent), (false, true, .needsConsent), (true, false, .needsHealthCheck),
            (true, true, .ready(hidesBalances: true)),
        ])
    func stage(consented: Bool, healthCheck: Bool, expected: AccountStage) async {
        let (api, _) = KiraAPI.routed([
            "GET /api/me": ok(meJSON(consented: consented, healthCheck: healthCheck, hideBalances: true))
        ])
        #expect(await AccountStage.check(with: api) == expected)
    }

    @Test("an API that cannot answer gives no stage")
    func unreachable() async {
        let (api, _) = KiraAPI.routed([:])
        #expect(await AccountStage.check(with: api) == nil)
    }
}
