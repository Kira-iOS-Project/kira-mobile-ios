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

    /** Which Beranda to show: the debt-free focus, else first steps until the first transaction. */
    package let variant: Variant
    /** Today in WIB. */
    package let today: Date
    /** The first letters of the email's local part ("dinda@…" is Dinda). */
    package let displayName: String
    /** Whether amounts start hidden, as the account last chose. */
    package let hideBalances: Bool
    /** The pay period the money is counted in. */
    package let period: PayPeriod
    /** The money of the period; nil before the first transaction. */
    package let money: PeriodMoney?
    /** The engine's first step, if any. */
    package let step: ScoreStep?
    /** Where that step sits among the engine's steps. */
    package let stepPosition: StepPosition?
    /** The Kira Score; nil before the health check. */
    package let score: ScoreSummary?
    /** The seven days the weekly summary covers, when it is ready. */
    package let weeklySummary: DayRange?
    /** The first steps of BRD-02. */
    package let checklist: FirstStepsChecklist?
    /** The paid-off share of BRD-03. */
    package let debtPlan: DebtPlanProgress?
    /** The emergency-fund micro target of BRD-03. */
    package let microTarget: MicroTarget?

    /** Beranda with every field given; the optional parts default to absent. */
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

    /** A period whose payday is `daysUntilPayday` days away. */
    package init(daysUntilPayday: Int) {
        self.daysUntilPayday = daysUntilPayday
    }
}

/** The money of the pay period: what came in, what went out, and what is left. */
package struct PeriodMoney: Equatable, Sendable {
    /** Income recorded this period, else the health check's net monthly income. */
    package let income: Int
    /** Expenses recorded this period. */
    package let spent: Int
    /** Income less expenses. */
    package let remaining: Int
    /** What is left for each day until payday, today included. */
    package let perDay: Int
    /** Spent as a share of income, in whole percent. */
    package let spentPercent: Int

    /** The period's money with every field given. */
    package init(income: Int, spent: Int, remaining: Int, perDay: Int, spentPercent: Int) {
        self.income = income
        self.spent = spent
        self.remaining = remaining
        self.perDay = perDay
        self.spentPercent = spentPercent
    }
}

/** Where the shown step sits among the engine's steps ("1 dari 3"). */
package struct StepPosition: Equatable, Sendable {
    /** The step's place, from 1. */
    package let index: Int
    /** How many steps the engine has. */
    package let total: Int

    /** Step `index` of `total`. */
    package init(index: Int, total: Int) {
        self.index = index
        self.total = total
    }
}

/** The Kira Score as Beranda shows it. */
package struct ScoreSummary: Equatable, Sendable {
    /** The score, 0–100. */
    package let score: Int
    /** The band the engine sent. */
    package let band: ScoreBand
    /** The change since the previous payday period, nil when there is none. */
    package let delta: Int?
    /** Whether the score comes from the health check alone. */
    package let isInitial: Bool

    /** The score with every field given. */
    package init(score: Int, band: ScoreBand, delta: Int?, isInitial: Bool) {
        self.score = score
        self.band = band
        self.delta = delta
        self.isInitial = isInitial
    }

    /** What the small line beside the score says. */
    package var trend: ScoreTrend { ScoreTrend(band: band, delta: delta, isInitial: isInitial) }
}
