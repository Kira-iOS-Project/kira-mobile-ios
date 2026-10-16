import APIClient
import Testing

@testable import Features

@Suite("AccountStage")
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
