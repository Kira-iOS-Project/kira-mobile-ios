/**
 The canvas's sample Beranda (boards Main, BerandaBaru, BerandaBebasUtang): Dinda on 15 October
 2026 and Bima in the debt-free segment. The loading placeholder draws the overview redacted.
 */
import Domain
import Foundation

nonisolated extension HomeOverview {
    /** 15 October 2026, 00.00 WIB, plus `days`. */
    /** The boards' period: 25 September – 24 Oktober 2026, payday ten days after 15 October. */
    private static let period = PayPeriod(
        start: CalendarDay(year: 2026, month: 9, day: 25), end: CalendarDay(year: 2026, month: 10, day: 24),
        daysUntilPayday: 10)

    private static func october15(plus days: Int = 0) -> Date {
        Date(timeIntervalSince1970: 1_791_997_200 + TimeInterval(days * 86_400))
    }

    /** "Lunasi Paylater A": Rp420.000,00 left, five points. */
    private static let payOffPaylaterA: ScoreStep = {
        var step = ScoreStep(kind: .payOffDebt, estimatedGain: 5)
        step.debtName = "Paylater A"
        step.remaining = 420_000
        return step
    }()

    private static let seekReliefOnlineLoan: ScoreStep = {
        var step = ScoreStep(kind: .seekRelief, estimatedGain: 0)
        step.debtName = "Pinjol B"
        return step
    }()

    /** BRD-01 (board Main). */
    static let sampleOverview = HomeOverview(
        variant: .overview, today: october15(), displayName: "Dinda", hideBalances: false,
        period: period,
        money: PeriodMoney(
            income: 7_500_000, spent: 5_660_000, remaining: 1_840_000, perDay: 184_000, spentPercent: 75),
        step: payOffPaylaterA,
        stepPosition: StepPosition(index: 1, total: 3),
        score: ScoreSummary(score: 66, band: .coping, delta: 4, isInitial: false),
        weeklySummary: DayRange(first: CalendarDay(october15(plus: -7)), last: CalendarDay(october15(plus: -1))))

    /** BRD-02 (board BerandaBaru). */
    static let sampleFirstSteps = HomeOverview(
        variant: .firstSteps, today: october15(), displayName: "Dinda", hideBalances: false,
        period: period,
        score: ScoreSummary(score: 62, band: .coping, delta: nil, isInitial: true),
        checklist: FirstStepsChecklist(healthCheck: true, firstTransaction: false, paydaySet: false))

    /** BRD-03 (board BerandaBebasUtang). */
    static let sampleDebtPlan = HomeOverview(
        variant: .debtPlan, today: october15(), displayName: "Bima", hideBalances: false,
        period: period,
        step: seekReliefOnlineLoan,
        score: ScoreSummary(score: 28, band: .vulnerable, delta: nil, isInitial: true),
        debtPlan: DebtPlanProgress(paidOff: 1_600_000, total: 20_000_000, remaining: 18_400_000, percent: 8),
        microTarget: MicroTarget(kind: .oneWeek, current: 120_000, target: 350_000))

    /** What the loading screen draws, redacted. */
    static let placeholder = sampleOverview
}
