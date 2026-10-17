import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Riwayat Kira Score through the live service: months as days, nil before the health check, problems by code. */
@Suite("LiveScoreService history")
struct ScoreHistoryMappingTests {
    private func reply(previousMonth: String = #""2026-09""#, month: String = "2026-10") -> RoutedTransport.Reply {
        ok(
            #"""
            {"current":{"score":66,"band":"coping","deltaFromPrevious":4,"previousMonth":\#(previousMonth)},
            "points":[{"month":"\#(month)","score":66}],
            "changes":[{"indicator":"emergency_fund","fromLabel":"0,8×","toLabel":"1,1×",\#
            "fromPoints":25,"toPoints":50}],"unchangedCount":5}
            """#)
    }

    @Test("the board's history, each month as its first day")
    func history() async throws {
        let (api, _) = KiraAPI.routed(["GET /api/score/history": reply()])
        let history = try #require(try await LiveScoreService(api: api).history(.sixMonths))
        #expect(history.score == 66 && history.band == .coping && history.deltaFromPrevious == 4)
        #expect(history.previousMonth == CalendarDay(year: 2026, month: 9, day: 1))
        #expect(history.points == [ScoreHistoryPoint(month: CalendarDay(year: 2026, month: 10, day: 1), score: 66)])
        #expect(
            history.changes == [
                IndicatorChange(
                    indicator: .emergencyFund, fromLabel: "0,8×", toLabel: "1,1×", fromPoints: 25, toPoints: 50)
            ])
        #expect(history.unchangedCount == 5)
    }

    @Test("no month before is nil; a month it cannot read is the generic problem")
    func months() async throws {
        let (none, _) = KiraAPI.routed(["GET /api/score/history": reply(previousMonth: "null")])
        #expect(try await LiveScoreService(api: none).history(.sixMonths)?.previousMonth == nil)
        let (bad, _) = KiraAPI.routed(["GET /api/score/history": reply(month: "2026-13")])
        await #expect(throws: AppProblem.self) { try await LiveScoreService(api: bad).history(.oneYear) }
    }

    @Test("nil before the health check; every other problem by its code; a lost connection as such")
    func problems() async throws {
        let (before, _) = KiraAPI.routed(["GET /api/score/history": problem("SCORE_NOT_AVAILABLE", status: 404)])
        #expect(try await LiveScoreService(api: before).history(.sixMonths) == nil)
        let problems = [("AUTH_UNAUTHENTICATED", 401), ("PLAN_FEATURE_UNAVAILABLE", 403), ("VALIDATION_FAILED", 422)]
        for (code, status) in problems {
            let (api, _) = KiraAPI.routed(["GET /api/score/history": problem(code, status: status)])
            do {
                _ = try await LiveScoreService(api: api).history(.oneYear)
                Issue.record("\(code) returned")
            } catch {
                #expect((error as? AppProblem)?.code == code)
            }
        }
        do {
            _ = try await LiveScoreService(api: OfflineTransport.offline).history(.sixMonths)
            Issue.record("offline returned")
        } catch {
            #expect(AppProblem(error).isConnectionLoss)
        }
    }

    @Test("Kira Plus includes the history, Gratis and Muda do not; an unreadable GET /me leaves it to the history")
    func includesHistory() async {
        for (plan, expected) in [("plus", true), ("free", false), ("young", false)] {
            let json = meJSON(plan: #"{"id":"\#(plan)","source":null,"renewsOn":null}"#)
            let (api, _) = KiraAPI.routed(["GET /api/me": ok(json)])
            #expect(await LiveScoreService(api: api).includesHistory() == expected)
        }
        #expect(await LiveScoreService(api: OfflineTransport.offline).includesHistory())
    }
}
