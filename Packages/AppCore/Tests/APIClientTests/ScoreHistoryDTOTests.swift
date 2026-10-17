import Domain
import Testing

@testable import APIClient

/** `GET /api/score/history` through a canned transport: the range it asks for and what it reads. */
@Suite("ScoreHistoryDTO")
struct ScoreHistoryDTOTests {
    private let json = #"""
        {"current":{"score":66,"band":"coping","deltaFromPrevious":4,"previousMonth":"2026-09"},
        "points":[{"month":"2026-09","score":62},{"month":"2026-10","score":66}],
        "changes":[{"indicator":"emergency_fund","fromLabel":"0,8×","toLabel":"1,1×","fromPoints":25,"toPoints":50},
        {"indicator":"protection_cover","fromLabel":null,"toLabel":"2 dari 2","fromPoints":50,"toPoints":100}],
        "unchangedCount":4}
        """#

    @Test("asks for the range and reads the score, the points and the changes")
    func reads() async throws {
        let (api, transport) = KiraAPI.canned(json: json)
        let history = try await api.getScoreHistory(.oneYear)
        let request = try #require(await transport.request)
        #expect(request.method == .get && request.path.hasSuffix("score/history?range=1y"))
        #expect(history.score == 66 && history.band == .coping && history.deltaFromPrevious == 4)
        #expect(history.previousMonth == "2026-09" && history.unchangedCount == 4)
        #expect(history.points == [.init(month: "2026-09", score: 62), .init(month: "2026-10", score: 66)])
        #expect(history.changes.map(\.indicator) == [.emergencyFund, .protection])
        #expect(history.changes.map(\.fromLabel) == ["0,8×", nil] && history.changes[1].toPoints == 100)
    }

    @Test("throws every problem the route answers")
    func problems() async {
        await expectProblems([401, 404, 422]) { _ = try await $0.getScoreHistory(.sixMonths) }
    }
}
