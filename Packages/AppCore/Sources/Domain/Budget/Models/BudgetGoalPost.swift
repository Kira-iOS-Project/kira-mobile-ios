/** A server-defined savings goal and its progress. */
import Foundation

/** A savings goal shown on Budget: how far it has come. */
package struct BudgetGoalPost: Equatable, Sendable {
    /** The goal's category, as the API names it. */
    package let category: String
    /** The goal's name. */
    package let name: String
    /** Whole rupiah saved so far, never below 0. */
    package let currentAmount: Int
    /** Whole rupiah the goal needs, never below 0. */
    package let targetAmount: Int

    /** A goal with its progress; negative amounts read as 0. */
    package init(
        category: String, name: String, currentAmount: Int, targetAmount: Int
    ) {
        self.category = category
        self.name = name
        self.currentAmount = max(0, currentAmount)
        self.targetAmount = max(0, targetAmount)
    }
}
