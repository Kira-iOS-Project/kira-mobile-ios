/**
 What the score engine measured for one indicator, from which the app writes its sentence.
 Ratios come rounded by the server: the emergency fund to one decimal, percents to whole numbers.
 */
package enum IndicatorMeasure: Hashable, Sendable {
    /** Liquid money against essential spending, in months, and the target multiple. */
    case emergencyFund(ratio: Double, liquid: Int, essential: Int, targetMultiple: Int, targetAmount: Int)
    /** Monthly savings as a percent of income. */
    case savingsRatio(percent: Int, monthlySavings: Int, income: Int)
    /** Monthly instalments as a percent of income. */
    case instalmentRatio(percent: Int, monthlyInstalments: Int, income: Int)
    /** Consumer-debt platforms and whether any is late or overdue. */
    case consumerDebt(platforms: Int, anyLate: Bool, anyOverdue: Bool)
    /** Total debt as a percent of total assets. */
    case debtToAsset(percent: Int, totalDebt: Int, totalAssets: Int)
    /** Whether health and income cover are held. */
    case protectionCover(health: Bool, income: Bool)
}
