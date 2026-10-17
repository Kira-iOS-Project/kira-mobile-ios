/** A category's planned amount and spending in the active pay period. */
import Foundation

package struct BudgetAllocation: Equatable, Sendable {
    /** The expense category this amount belongs to. */
    package let category: TransactionCategory
    /** Whole rupiah set aside for the category. */
    package let amount: Int
    /** Whole rupiah already spent in the active period. */
    package let spent: Int
    /** Server-computed near-limit state, when included in the response. */
    package let nearLimit: Bool?

    /** The category allocation and its current spending. */
    package init(category: TransactionCategory, amount: Int, spent: Int = 0, nearLimit: Bool? = nil) {
        self.category = category
        self.amount = max(0, amount)
        self.spent = max(0, spent)
        self.nearLimit = nearLimit
    }

    /** Whether this category has used at least 90% of its allocation. */
    package var isNearLimit: Bool {
        nearLimit ?? (amount > 0 && spent >= amount - amount / 10)
    }

    /** Spending relative to the plan, capped for a progress bar. */
    package var progress: Double {
        guard amount > 0 else { return 0 }
        return min(Double(spent) / Double(amount), 1)
    }
}
