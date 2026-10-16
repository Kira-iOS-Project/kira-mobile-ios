import Domain

/** What an indicator measured, by indicator: the app writes "1,1× pengeluaran pokok" from it. */
package enum IndicatorMeasure: Hashable, Sendable {
    /** Liquid savings as a multiple of essential spending, against the target multiple. */
    case emergencyFund(ratio: Double, liquid: Int, essential: Int, targetMultiple: Double, targetAmount: Int)
    /** Monthly savings as a whole percent of income. */
    case savingsRatio(percent: Int, monthlySavings: Int, income: Int)
    /** Monthly instalments as a whole percent of income. */
    case instalmentRatio(percent: Int, monthlyInstalments: Int, income: Int)
    /** Open consumer-debt platforms, and whether any is late or overdue. */
    case consumerDebt(platforms: Int, anyLate: Bool, anyOverdue: Bool)
    /** Total debt as a whole percent of total assets. */
    case debtToAsset(percent: Int, totalDebt: Int, totalAssets: Int)
    /** Whether health cover and income cover are held. */
    case protection(health: Bool, income: Bool)

    /** The branch the indicator's key names; a missing branch means the spec and app disagree. */
    init(key: IndicatorKey, _ measure: Components.Schemas.IndicatorMeasure) throws {
        switch key {
        case .emergencyFund:
            guard let fund = measure.value1 else { throw AppProblem() }
            self = .emergencyFund(
                ratio: fund.ratio, liquid: fund.liquid, essential: fund.essential,
                targetMultiple: fund.targetMultiple, targetAmount: fund.targetAmount)
        case .savingsRatio:
            guard let savings = measure.value2 else { throw AppProblem() }
            self = .savingsRatio(percent: savings.percent, monthlySavings: savings.monthlySavings,
                income: savings.income)
        case .instalmentRatio:
            guard let ratio = measure.value3 else { throw AppProblem() }
            self = .instalmentRatio(
                percent: ratio.percent, monthlyInstalments: ratio.monthlyInstalments, income: ratio.income)
        case .consumerDebt:
            guard let debt = measure.value4 else { throw AppProblem() }
            self = .consumerDebt(platforms: debt.platforms, anyLate: debt.anyLate, anyOverdue: debt.anyOverdue)
        case .debtToAsset:
            guard let share = measure.value5 else { throw AppProblem() }
            self = .debtToAsset(percent: share.percent, totalDebt: share.totalDebt, totalAssets: share.totalAssets)
        case .protection:
            guard let cover = measure.value6 else { throw AppProblem() }
            self = .protection(health: cover.health, income: cover.income)
        }
    }
}
