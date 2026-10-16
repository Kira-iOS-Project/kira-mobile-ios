/** Beranda's whole answer; each layout fills its own parts and leaves the rest nil. */
package struct HomeDTO: Hashable, Sendable {
    /** Which Beranda to draw. */
    package let variant: HomeVariantDTO
    /** Today in WIB (`YYYY-MM-DD`), for "Kamis, 15 Oktober 2026". */
    package let today: String
    /** "Halo, Dinda". */
    package let displayName: String
    /** Amounts show as Rp•••••• when true. */
    package let hideBalances: Bool
    /** The payday period. */
    package let period: PaydayPeriodDTO
    /** Sisa uang (overview). */
    package let money: HomeMoneyDTO?
    /** Langkah Berikutnya (overview, debt plan). */
    package let step: ScoreStepDTO?
    /** The step's place among the engine's steps ("1 dari 3"). */
    package let stepPosition: StepPositionDTO?
    /** The score card; nil before the health check. */
    package let score: HomeScoreDTO?
    /** Ringkasan Mingguan Siap (overview). */
    package let weeklySummary: DateRangeDTO?
    /** Langkah Awal (first steps). */
    package let checklist: HomeChecklistDTO?
    /** Rencana bebas utang (debt plan). */
    package let debtPlan: DebtPlanDTO?
    /** Target mikro (debt plan). */
    package let microTarget: MicroTargetDTO?

    init(_ home: Components.Schemas.Home) throws {
        variant = try bridged(home.variant)
        today = home.today
        displayName = home.displayName
        hideBalances = home.hideBalances
        period = PaydayPeriodDTO(home.period)
        money = home.money.map {
            HomeMoneyDTO(income: $0.income, spent: $0.spent, remaining: $0.remaining, perDay: $0.perDay,
                spentPercent: $0.spentPercent)
        }
        step = try home.step.map { try ScoreStepDTO($0.value1) }
        stepPosition = home.stepPosition.map { StepPositionDTO(index: $0.index, total: $0.total) }
        score = try home.score.map {
            HomeScoreDTO(score: $0.score, band: try bridged($0.band), delta: $0.delta, isInitial: $0.isInitial)
        }
        weeklySummary = home.weeklySummary.map { DateRangeDTO(first: $0.from, last: $0.to) }
        checklist = home.checklist.map {
            HomeChecklistDTO(
                healthCheck: $0.healthCheck, firstTransaction: $0.firstTransaction, walletAdded: $0.walletAdded,
                paydaySet: $0.paydaySet)
        }
        debtPlan = home.debtPlan.map { DebtPlanDTO(paidOff: $0.paidOff, total: $0.total,
            remaining: $0.remaining, percent: $0.percent) }
        microTarget = try home.microTarget.map {
            MicroTargetDTO(kind: try bridged($0.kind), current: $0.current, target: $0.target)
        }
    }
}
