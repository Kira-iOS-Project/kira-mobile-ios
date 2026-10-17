import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LiveScoreService")
struct LiveScoreServiceTests {
    @Test("GET /me says whether the plan includes Portofolio: Kira Plus only")
    func planIncludesPortfolio() async throws {
        let (plus, _) = KiraAPI.routed(["GET /api/me": ok(meJSON())])
        #expect(try await LiveScoreService(api: plus).planIncludesPortfolio())
        let young = #"{"id":"young","source":"purchase","renewsOn":"2026-11-16"}"#
        let (other, _) = KiraAPI.routed(["GET /api/me": ok(meJSON(plan: young))])
        #expect(try await !LiveScoreService(api: other).planIncludesPortfolio())
    }

    @Test("GET /score becomes the Domain's report, every measure and step included")
    func score() async throws {
        let (api, _) = KiraAPI.routed(["GET /api/score": ok(reportJSON)])
        let report = try #require(try await LiveScoreService(api: api).score())
        #expect(report.score == 66 && report.band == .coping && report.delta == 4)
        #expect(report.nextCheckOn == CalendarDay(year: 2026, month: 10, day: 25).date)
        #expect(report.groups.map(\.group) == [.save, .debt, .protect])
        #expect(
            report.indicators.map(\.measure) == [
                .emergencyFund(
                    ratio: 1.1, liquid: 4_800_000, essential: 4_200_000, targetMultiple: 6, targetAmount: 25_200_000),
                .savingsRatio(percent: 8, monthlySavings: 600_000, income: 7_500_000),
                .instalmentRatio(percent: 18, monthlyInstalments: 1_350_000, income: 7_500_000),
                .consumerDebt(platforms: 2, anyLate: true, anyOverdue: false),
                .debtToAsset(percent: 32, totalDebt: 14_310_000, totalAssets: 44_700_000),
                .protectionCover(health: true, income: false),
            ])
        #expect(report.steps[0].kind == .payOffDebt && report.steps[0].debtName == "Paylater A")
        #expect(report.steps[0].remaining == 420_000)
        #expect(report.steps[1].targetMultiple == 4.5 && report.steps[1].targetAmount == 12_600_000)
        #expect(!report.cappedByConsumerDebt)
    }

    @Test("no score before the health check is nil; any other problem is thrown")
    func noScore() async throws {
        let (api, _) = KiraAPI.routed(["GET /api/score": problem("SCORE_NOT_AVAILABLE", status: 404)])
        #expect(try await LiveScoreService(api: api).score() == nil)
        let (failing, _) = KiraAPI.routed(["GET /api/score": problem("INTERNAL_ERROR", status: 401)])
        await #expect(throws: AppProblem.self) { try await LiveScoreService(api: failing).score() }
    }

    @Test("one indicator in full: ladder, next rung and milestones")
    func indicator() async throws {
        let (api, transport) = KiraAPI.routed(["GET /api/score/indicators/emergency_fund": ok(detailJSON)])
        let detail = try await LiveScoreService(api: api).indicator(.emergencyFund)
        #expect(detail.indicator.key == .emergencyFund && detail.indicator.points == 50)
        #expect(detail.ladder.map(\.points) == [100, 50])
        #expect(
            detail.ladder[1]
                == LadderRung(
                    points: 50, lower: 1, upper: 3, amountLower: 4_200_000, amountUpper: 12_600_000, isCurrent: true))
        #expect(detail.nextRung == NextRung(points: 75, amountNeeded: 7_800_000, scoreFrom: 66, scoreTo: 70))
        #expect(
            detail.milestones == [
                Milestone(amount: 4_200_000, label: "1×"), Milestone(amount: 12_600_000, label: "3×"),
            ])
        #expect(await transport.routes == ["GET /api/score/indicators/emergency_fund"])
    }
}
