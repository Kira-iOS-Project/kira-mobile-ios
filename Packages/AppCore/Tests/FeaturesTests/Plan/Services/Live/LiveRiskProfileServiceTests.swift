import APIClient
import Domain
import Foundation
import Testing

@testable import Features

private let moderateJSON = #"{"profile":"moderate","answers":[1,1,1,0,1],"updatedAt":"2026-10-17T02:00:00.000Z"}"#
private let emptyJSON = #"{"profile":null,"answers":null,"updatedAt":null}"#

@Suite("LiveRiskProfileService")
struct LiveRiskProfileServiceTests {
    private func service(_ replies: [String: RoutedTransport.Reply]) -> (LiveRiskProfileService, RoutedTransport) {
        let (api, transport) = KiraAPI.routed(replies)
        return (LiveRiskProfileService(api: api), transport)
    }

    @Test("PUT sends the five indexes and returns Moderat for the board's persona")
    func save() async throws {
        let (service, transport) = service(["PUT /api/risk-profile": ok(moderateJSON)])
        #expect(try await service.saveRiskProfile(answers: [1, 1, 1, 0, 1]) == .moderate)
        let sent = try #require(await transport.sent.first?.json)
        #expect(sent["answers"] == .array([.number(1), .number(1), .number(1), .number(0), .number(1)]))
    }

    @Test("GET reads the saved profile with its answers; all null before the quiz is no profile")
    func read() async throws {
        let (saved, _) = service(["GET /api/risk-profile": ok(moderateJSON)])
        #expect(
            try await saved.savedProfile()
                == SavedRiskProfile(profile: .moderate, answers: RiskAnswers([1, 1, 1, 0, 1])))
        let (empty, _) = service(["GET /api/risk-profile": ok(emptyJSON)])
        #expect(try await empty.savedProfile() == nil)
        let (unknown, _) = service(["GET /api/risk-profile": ok(#"{"profile":"","answers":[],"updatedAt":null}"#)])
        #expect(try await unknown.savedProfile() == nil)
    }

    @Test("a PUT answered without a profile is a generic problem")
    func saveWithoutProfile() async {
        let (service, _) = service(["PUT /api/risk-profile": ok(emptyJSON)])
        await #expect(throws: AppProblem()) { try await service.saveRiskProfile(answers: [1, 1, 1, 0, 1]) }
    }

    @Test(
        "every refusal of PUT reaches the screen as its problem",
        arguments: [("VALIDATION_FAILED", 422), ("AUTH_UNAUTHENTICATED", 401), ("INTERNAL_ERROR", 500)])
    func saveProblems(code: String, status: Int) async {
        let (service, _) = service(["PUT /api/risk-profile": problem(code, status: status)])
        await #expect(throws: AppProblem(type: AppProblem.typeBase + code, code: code, requestId: "r-1")) {
            try await service.saveRiskProfile(answers: [9, 1, 1, 0, 1])
        }
    }

    @Test(
        "every refusal of GET reaches the screen as its problem",
        arguments: [("AUTH_UNAUTHENTICATED", 401), ("INTERNAL_ERROR", 500)])
    func readProblems(code: String, status: Int) async {
        let (service, _) = service(["GET /api/risk-profile": problem(code, status: status)])
        await #expect(throws: AppProblem(type: AppProblem.typeBase + code, code: code, requestId: "r-1")) {
            try await service.savedProfile()
        }
    }

    @Test("a lost connection reads as one")
    func offline() async {
        let service = LiveRiskProfileService(api: .down)
        do {
            _ = try await service.saveRiskProfile(answers: [1, 1, 1, 0, 1])
            Issue.record("expected a problem")
        } catch {
            #expect(AppProblem(error).isConnectionLoss)
        }
    }
}
