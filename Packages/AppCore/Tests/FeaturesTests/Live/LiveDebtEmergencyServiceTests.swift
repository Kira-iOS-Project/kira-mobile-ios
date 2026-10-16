import APIClient
import Testing

@testable import Features

@Suite("LiveDebtEmergencyService")
struct LiveDebtEmergencyServiceTests {
    @Test("PUT /care/debt-emergency turns the mode on")
    func activates() async throws {
        let (api, transport) = KiraAPI.routed([
            "PUT /api/care/debt-emergency": ok(#"{"activatedAt":"2026-10-17T03:00:00.000Z"}"#)
        ])
        try await LiveDebtEmergencyService(api: api).activate()
        #expect(await transport.routes == ["PUT /api/care/debt-emergency"])
    }

    @Test("a refused session is its problem; an undocumented answer is a problem without a code")
    func failures() async throws {
        let (refused, _) = KiraAPI.routed([
            "PUT /api/care/debt-emergency": problem("AUTH_UNAUTHENTICATED", status: 401)
        ])
        let error = await #expect(throws: AppProblem.self) { try await LiveDebtEmergencyService(api: refused).activate() }
        #expect(error?.knownCode == .authUnauthenticated)
        let (broken, _) = KiraAPI.routed(["PUT /api/care/debt-emergency": problem("INTERNAL_ERROR", status: 500)])
        let undocumented = await #expect(throws: AppProblem.self) {
            try await LiveDebtEmergencyService(api: broken).activate()
        }
        #expect(undocumented?.knownCode == nil)
    }
}
