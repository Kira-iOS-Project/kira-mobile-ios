/** Additional context for editing a budget, including complete prior-period averages. */
import Foundation

package struct BudgetEditContext: Equatable, Sendable {
    package let budget: BudgetOverview
    package let averagePeriods: Int
    package let averages: [BudgetCategoryAverage]

    package init(budget: BudgetOverview, averagePeriods: Int, averages: [BudgetCategoryAverage]) {
        self.budget = budget
        self.averagePeriods = min(max(averagePeriods, 0), 3)
        self.averages = averages
    }
}

package struct BudgetCategoryAverage: Equatable, Sendable {
    package let category: TransactionCategory
    package let amount: Int

    package init(category: TransactionCategory, amount: Int) {
        self.category = category
        self.amount = max(0, amount)
    }
}
