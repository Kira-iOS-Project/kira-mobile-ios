/** The values sent when a person saves the current budget. */
import Foundation

package struct BudgetDraft: Equatable, Sendable {
    /** Monthly income from the existing health-check profile. */
    package var income: Int
    /** The chosen payday preference; the API resolves adjusted dates for the period. */
    package var payday: Payday
    /** Category allocations to persist. */
    package var allocations: [BudgetAllocation]

    /** The draft of the current plan. */
    package init(income: Int, payday: Payday, allocations: [BudgetAllocation]) {
        self.income = max(0, income)
        self.payday = payday
        self.allocations = allocations.map { BudgetAllocation(category: $0.category, amount: $0.amount) }
    }

    /** Total allocated, even when it exceeds income. */
    package var allocated: Int { allocations.reduce(0) { $0 + $1.amount } }

    /** The user may save an allocation above income, with the screen showing a warning. */
    package var isOverallocated: Bool { allocated > income }

    /** Sets one category's amount while preserving the existing list order. */
    package mutating func setAmount(_ amount: Int, for category: TransactionCategory) {
        if let index = allocations.firstIndex(where: { $0.category == category }) {
            allocations[index] = BudgetAllocation(category: category, amount: amount)
        } else {
            allocations.append(BudgetAllocation(category: category, amount: amount))
        }
    }

    /** Changes the income while preserving the category allocations. */
    package mutating func setIncome(_ income: Int) {
        self.income = max(0, income)
    }
}
