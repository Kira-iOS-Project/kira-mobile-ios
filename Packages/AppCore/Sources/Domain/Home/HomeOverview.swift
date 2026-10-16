import Foundation

/**
 Beranda's content, the `GET /home` aggregate: which variant to show, and the money, step, score,
 weekly summary, checklist and debt plan the engine computed. Amounts are whole rupiah; dates are
 WIB calendar days (see `HomeCalendar`).
 */
package struct HomeOverview: Equatable, Sendable {
    /** Which Beranda to show. */
    package enum Variant: String, CaseIterable, Sendable {
        /** BRD-02: no transaction yet, the first steps. */
        case firstSteps = "first_steps"
        /** BRD-01: the money left this pay period. */
        case overview
        /** BRD-03: the person chose to get out of debt. */
        case debtPlan = "debt_plan"
    }

    package let variant: Variant
    /** Today in WIB. */
    package let today: Date
    package let displayName: String
    package let hideBalances: Bool
    package let period: PayPeriod
    package let money: PeriodMoney?
    package let step: ScoreStep?
    package let stepPosition: StepPosition?
    package let score: ScoreSummary?
    /** The seven days the weekly summary covers, when it is ready. */
    package let weeklySummary: DayRange?
    package let checklist: FirstStepsChecklist?
    package let debtPlan: DebtPlanProgress?
    package let microTarget: MicroTarget?

    package init(
        variant: Variant, today: Date, displayName: String, hideBalances: Bool, period: PayPeriod,
        money: PeriodMoney? = nil, step: ScoreStep? = nil, stepPosition: StepPosition? = nil,
        score: ScoreSummary? = nil, weeklySummary: DayRange? = nil, checklist: FirstStepsChecklist? = nil,
        debtPlan: DebtPlanProgress? = nil, microTarget: MicroTarget? = nil
    ) {
        self.variant = variant
        self.today = today
        self.displayName = displayName
        self.hideBalances = hideBalances
        self.period = period
        self.money = money
        self.step = step
        self.stepPosition = stepPosition
        self.score = score
        self.weeklySummary = weeklySummary
        self.checklist = checklist
        self.debtPlan = debtPlan
        self.microTarget = microTarget
    }

    /** The avatar's letter: the first letter of the display name, capitalised. */
    package var initial: String {
        displayName.first.map { String($0).uppercased() } ?? ""
    }
}

/** The pay period the money is counted in: how far away the next payday is. */
package struct PayPeriod: Equatable, Sendable {
    /** Days until the next payday; 0 is today. */
    package let daysUntilPayday: Int

    package init(daysUntilPayday: Int) {
        self.daysUntilPayday = daysUntilPayday
    }
}

/** The money of the pay period: what came in, what went out, and what is left. */
package struct PeriodMoney: Equatable, Sendable {
    package let income: Decimal
    package let spent: Decimal
    package let remaining: Decimal
    package let perDay: Decimal
    package let spentPercent: Int

    package init(income: Decimal, spent: Decimal, remaining: Decimal, perDay: Decimal, spentPercent: Int) {
        self.income = income
        self.spent = spent
        self.remaining = remaining
        self.perDay = perDay
        self.spentPercent = spentPercent
    }
}

/** Where the shown step sits among the engine's steps ("1 dari 3"). */
package struct StepPosition: Equatable, Sendable {
    package let index: Int
    package let total: Int

    package init(index: Int, total: Int) {
        self.index = index
        self.total = total
    }
}

/** The Kira Score as Beranda shows it. */
package struct ScoreSummary: Equatable, Sendable {
    package let score: Score
    package let band: ScoreBand
    package let delta: Int?
    package let isInitial: Bool

    package init(score: Score, band: ScoreBand, delta: Int?, isInitial: Bool) {
        self.score = score
        self.band = band
        self.delta = delta
        self.isInitial = isInitial
    }

    /** What the small line beside the score says. */
    package var trend: ScoreTrend { ScoreTrend(band: band, delta: delta, isInitial: isInitial) }
}
