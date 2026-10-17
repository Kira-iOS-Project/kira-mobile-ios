/** The current budget, including the server-adjusted pay period and this period's spending. */
import Foundation

package struct BudgetOverview: Equatable, Sendable {
    /** The monthly income used to size the plan. */
    package let income: Int
    /** Income remaining after spending reported by the server for this period. */
    package let remaining: Int
    /** Whether category allocations have been configured for this account. */
    package let isConfigured: Bool
    /** The payday preference saved by the person. */
    package let payday: Payday
    /** The period the server resolved from the adjusted payday. */
    package let period: PayPeriod
    /** Planned and spent amounts, in the API's stable category order. */
    package let allocations: [BudgetAllocation]
    /** Savings goals returned by the budget API. */
    package let goalPosts: [BudgetGoalPost]

    /** The current budget and its period. */
    package init(
        income: Int, remaining: Int? = nil, goalPosts: [BudgetGoalPost] = [], payday: Payday,
        period: PayPeriod, allocations: [BudgetAllocation], isConfigured: Bool = true
    ) {
        let normalizedIncome = max(0, income)
        self.income = normalizedIncome
        self.remaining = remaining ?? (normalizedIncome - allocations.reduce(0) { $0 + $1.spent })
        self.isConfigured = isConfigured
        self.payday = payday
        self.period = period
        self.allocations = allocations
        self.goalPosts = goalPosts
    }

    /** Total amount allocated across categories. */
    package var allocated: Int { allocations.reduce(0) { $0 + $1.amount } }

    /** Spending across the categories for the active period. */
    package var spent: Int { allocations.reduce(0) { $0 + $1.spent } }

    /** Whether the plan assigns more than the monthly income; allowed but surfaced as a warning. */
    package var isOverallocated: Bool { allocated > income }

    /** The editable plan, with current spending excluded from each allocation. */
    package var draft: BudgetDraft {
        BudgetDraft(
            income: income, payday: payday,
            allocations: allocations.map { BudgetAllocation(category: $0.category, amount: $0.amount) })
    }

}
