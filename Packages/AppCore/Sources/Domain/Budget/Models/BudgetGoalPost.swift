/** A server-defined savings goal with progress markers. */
import Foundation

/** A savings goal shown on Budget: how far it has come and its markers. */
package struct BudgetGoalPost: Equatable, Sendable {
    /** The goal's category, as the API names it. */
    package let category: String
    /** The goal's name. */
    package let name: String
    /** Whole rupiah saved so far, never below 0. */
    package let currentAmount: Int
    /** Whole rupiah the goal needs, never below 0. */
    package let targetAmount: Int
    /** The markers along the way. */
    package let milestones: [BudgetGoalMilestone]

    /** A goal with its progress; negative amounts read as 0. */
    package init(
        category: String, name: String, currentAmount: Int, targetAmount: Int,
        milestones: [BudgetGoalMilestone]
    ) {
        self.category = category
        self.name = name
        self.currentAmount = max(0, currentAmount)
        self.targetAmount = max(0, targetAmount)
        self.milestones = milestones
    }
}

/** One marker on a savings goal's way. */
package struct BudgetGoalMilestone: Equatable, Sendable {
    /** Whole rupiah at this marker, never below 0. */
    package let amount: Int
    /** The marker's label. */
    package let label: String
    /** Whether the savings have reached it. */
    package let reached: Bool

    /** A marker; a negative amount reads as 0. */
    package init(amount: Int, label: String, reached: Bool) {
        self.amount = max(0, amount)
        self.label = label
        self.reached = reached
    }
}
