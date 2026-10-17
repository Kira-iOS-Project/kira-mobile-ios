/** A server-defined savings goal with progress markers. */
import Foundation

package struct BudgetGoalPost: Equatable, Sendable {
    package let category: String
    package let name: String
    package let currentAmount: Int
    package let targetAmount: Int
    package let milestones: [BudgetGoalMilestone]

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

package struct BudgetGoalMilestone: Equatable, Sendable {
    package let amount: Int
    package let label: String
    package let reached: Bool

    package init(amount: Int, label: String, reached: Bool) {
        self.amount = max(0, amount)
        self.label = label
        self.reached = reached
    }
}
