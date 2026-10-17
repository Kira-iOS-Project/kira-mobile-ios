import Foundation

/**
 What the quiz shows from the person's numbers (`GET /plan`): the emergency fund as a multiple of
 the essential monthly spending and its target multiple (the ladder's `emergency_fund` step), and
 the monthly income the fifth question's ranges are cut from. Each may be unknown (null).
 */
package struct RiskQuizContext: Hashable, Sendable {
    /** Nothing known: no ladder notice, and the board's ranges without the income clause. */
    package static let unknown = Self(emergencyMultiple: nil, emergencyTarget: nil, monthlyIncome: nil)
    /** The board's income, Rp7.500.000,00: the ranges shown while the income is unknown. */
    package static let boardIncome = 7_500_000

    /** The emergency fund today, in months of essential spending (1.1, written "1,1×"). */
    package let emergencyMultiple: Double?
    /** The target, in months (6, written "6×"). */
    package let emergencyTarget: Int?
    /** The monthly income in rupiah (7500000). */
    package let monthlyIncome: Int?

    /** A context. */
    package init(emergencyMultiple: Double?, emergencyTarget: Int?, monthlyIncome: Int?) {
        self.emergencyMultiple = emergencyMultiple
        self.emergencyTarget = emergencyTarget
        self.monthlyIncome = monthlyIncome
    }

    /** The context of `plan`: its emergency-fund step's multiples and the prefill's income. */
    package init(plan: PlanOverview) {
        let detail = plan.ladder.first { $0.key == .emergencyFund }?.detail
        self.init(
            emergencyMultiple: detail?.multiple, emergencyTarget: detail?.targetMultiple,
            monthlyIncome: plan.prefill.monthlyIncome)
    }

    /** The two multiples while the fund is still below its target, which is when the ladder notice shows. */
    package var ladder: (multiple: Double, target: Int)? {
        guard let multiple = emergencyMultiple, let target = emergencyTarget, multiple < Double(target) else {
            return nil
        }
        return (multiple, target)
    }

    /** The fifth question's four ranges: from the income, or the board's while it is unknown. */
    package var depositRanges: MonthlyDepositRanges {
        MonthlyDepositRanges(income: Decimal(monthlyIncome ?? Self.boardIncome))
    }
}
