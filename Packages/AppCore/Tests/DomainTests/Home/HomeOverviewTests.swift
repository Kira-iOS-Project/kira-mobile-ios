import Foundation
import Testing

@testable import Domain

@Suite("HomeOverview")
struct HomeOverviewTests {
    private func overview(name: String) -> HomeOverview {
        HomeOverview(
            variant: .overview, today: wibDay(2026, 10, 15), displayName: name, hideBalances: false,
            period: PayPeriod(daysUntilPayday: 10))
    }

    @Test("names the avatar by the first letter of the name, capitalised")
    func initial() {
        #expect(overview(name: "dinda").initial == "D")
        #expect(overview(name: "").initial == "")
    }

    @Test("keeps what it was given")
    func members() {
        let money = PeriodMoney(
            income: 7_500_000, spent: 5_660_000, remaining: 1_840_000, perDay: 184_000, spentPercent: 75)
        let home = HomeOverview(
            variant: .debtPlan, today: wibDay(2026, 10, 15), displayName: "Bima", hideBalances: true,
            period: PayPeriod(daysUntilPayday: 3), money: money, step: ScoreStep(kind: .seekRelief, estimatedGain: 0),
            stepPosition: StepPosition(index: 1, total: 3),
            score: ScoreSummary(score: 28, band: .vulnerable, delta: nil, isInitial: true),
            weeklySummary: DayRange(first: wibDay(2026, 10, 8), last: wibDay(2026, 10, 14)),
            checklist: FirstStepsChecklist(healthCheck: true, firstTransaction: false, paydaySet: false),
            debtPlan: DebtPlanProgress(paidOff: 0, total: 1, remaining: 1, percent: 0),
            microTarget: MicroTarget(kind: .oneWeek, current: 120_000, target: 350_000))
        #expect(home.money?.perDay == 184_000)
        #expect(home.stepPosition == StepPosition(index: 1, total: 3))
        #expect(home.score?.trend == .startingPoint)
        #expect(home.period.daysUntilPayday == 3)
        #expect(home.microTarget?.kind == .oneWeek)
        #expect(HomeOverview.Variant(rawValue: "first_steps") == .firstSteps)
    }

    @Test("counts the first steps done, out of the three it shows")
    func checklist() {
        let none = FirstStepsChecklist(healthCheck: false, firstTransaction: false, paydaySet: false)
        let two = FirstStepsChecklist(healthCheck: true, firstTransaction: false, paydaySet: true)
        #expect(none.doneCount == 0)
        #expect(two.doneCount == 2)
        #expect(two.total == 3)
    }

    @Test("says whether any debt is paid off")
    func debtPlan() {
        #expect(DebtPlanProgress(paidOff: 1_600_000, total: 20_000_000, remaining: 18_400_000, percent: 8).hasPaidSome)
        #expect(!DebtPlanProgress(paidOff: 0, total: 20_000_000, remaining: 20_000_000, percent: 0).hasPaidSome)
    }

    struct TrendCase: Sendable {
        let band: ScoreBand
        let delta: Int?
        let isInitial: Bool
        let trend: ScoreTrend
    }

    @Test(
        "describes the score's change, a starting point for Rentan, or the first check",
        arguments: [
            TrendCase(band: .coping, delta: 4, isInitial: false, trend: .rise(4)),
            TrendCase(band: .coping, delta: -3, isInitial: false, trend: .fall(3)),
            TrendCase(band: .vulnerable, delta: 0, isInitial: false, trend: .unchanged),
            TrendCase(band: .vulnerable, delta: nil, isInitial: true, trend: .startingPoint),
            TrendCase(band: .coping, delta: nil, isInitial: true, trend: .firstCheck),
            TrendCase(band: .healthy, delta: nil, isInitial: false, trend: .none),
        ])
    func trend(_ row: TrendCase) {
        let summary = ScoreSummary(score: 50, band: row.band, delta: row.delta, isInitial: row.isInitial)
        #expect(summary.trend == row.trend)
    }
}
