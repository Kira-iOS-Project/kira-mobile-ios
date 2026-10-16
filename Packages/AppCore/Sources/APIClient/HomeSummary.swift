/** Beranda's whole answer; each layout fills its own parts and leaves the rest nil. */
package struct HomeSummary: Hashable, Sendable {
    /** Which Beranda to draw. */
    package let variant: HomeVariant
    /** Today in WIB (`YYYY-MM-DD`), for "Kamis, 15 Oktober 2026". */
    package let today: String
    /** "Halo, Dinda". */
    package let displayName: String
    /** Amounts show as Rp•••••• when true. */
    package let hideBalances: Bool
    /** The payday period. */
    package let period: PaydayPeriod
    /** Sisa uang (overview). */
    package let money: HomeMoney?
    /** Langkah Berikutnya (overview, debt plan). */
    package let step: ScoreStep?
    /** The step's place among the engine's steps ("1 dari 3"). */
    package let stepPosition: StepPosition?
    /** The score card; nil before the health check. */
    package let score: HomeScore?
    /** Ringkasan Mingguan Siap (overview). */
    package let weeklySummary: DateRange?
    /** Langkah Awal (first steps). */
    package let checklist: HomeChecklist?
    /** Rencana bebas utang (debt plan). */
    package let debtPlan: DebtPlan?
    /** Target mikro (debt plan). */
    package let microTarget: MicroTarget?

    init(_ home: Components.Schemas.Home) throws {
        variant = try bridged(home.variant)
        today = home.today
        displayName = home.displayName
        hideBalances = home.hideBalances
        period = PaydayPeriod(home.period)
        money = home.money.map {
            HomeMoney(income: $0.income, spent: $0.spent, remaining: $0.remaining, perDay: $0.perDay,
                spentPercent: $0.spentPercent)
        }
        step = try home.step.map { try ScoreStep($0.value1) }
        stepPosition = home.stepPosition.map { StepPosition(index: $0.index, total: $0.total) }
        score = try home.score.map {
            HomeScore(score: $0.score, band: try bridged($0.band), delta: $0.delta, isInitial: $0.isInitial)
        }
        weeklySummary = home.weeklySummary.map { DateRange(first: $0.from, last: $0.to) }
        checklist = home.checklist.map {
            HomeChecklist(
                healthCheck: $0.healthCheck, firstTransaction: $0.firstTransaction, walletAdded: $0.walletAdded,
                paydaySet: $0.paydaySet)
        }
        debtPlan = home.debtPlan.map { DebtPlan(paidOff: $0.paidOff, total: $0.total,
            remaining: $0.remaining, percent: $0.percent) }
        microTarget = try home.microTarget.map {
            MicroTarget(kind: try bridged($0.kind), current: $0.current, target: $0.target)
        }
    }
}
