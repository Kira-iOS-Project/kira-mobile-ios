/** A category's planned amount and spending in the active pay period. */

/** One category of the budget: what is set aside, what is spent, and whether it nears its limit. */
package struct BudgetAllocation: Equatable, Sendable {
    /** The expense category this amount belongs to. */
    package let category: TransactionCategory
    /** Whole rupiah set aside for the category, never below 0. */
    package let amount: Int
    /** Whole rupiah already spent in the active period, never below 0. */
    package let spent: Int
    /** Whether the category nears its limit: the API's verdict, or at least 90% used. */
    package let isNearLimit: Bool

    /** A category with the API's near-limit verdict. */
    package init(category: TransactionCategory, amount: Int, spent: Int, nearLimit: Bool) {
        self.category = category
        self.amount = max(0, amount)
        self.spent = max(0, spent)
        isNearLimit = nearLimit
    }

    /** A category judged here: near its limit once at least 90% of a positive amount is spent. */
    package init(category: TransactionCategory, amount: Int, spent: Int = 0) {
        let amount = max(0, amount)
        let spent = max(0, spent)
        self.init(
            category: category, amount: amount, spent: spent,
            nearLimit: amount > 0 && spent >= amount - amount / 10)
    }
}
