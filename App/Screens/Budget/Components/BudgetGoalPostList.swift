/** Savings goal posts returned with the current budget. */
import Domain
import SwiftUI

struct BudgetGoalPostList: View {
    let goals: [BudgetGoalPost]

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            KiraSectionTitle("budget.goals")
            ForEach(Array(goals.enumerated()), id: \.offset) { _, goal in
                goalCard(goal)
            }
        }
    }

    private func goalCard(_ goal: BudgetGoalPost) -> some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            Text(goal.name).font(.headline).foregroundStyle(.ink)
            HStack {
                Text("budget.goal.current").font(.caption).foregroundStyle(.inkMuted)
                Spacer(minLength: KiraSpacing.space2)
                KiraAmount(Decimal(goal.currentAmount), size: .small)
                Text("budget.goal.separator").font(.caption).foregroundStyle(.inkMuted)
                KiraAmount(Decimal(goal.targetAmount), size: .small)
            }
            KiraProgressRibbon(
                value: Double(goal.currentAmount), target: Double(max(goal.targetAmount, 1)),
                label: "budget.goal.progress"
            )
            milestones(goal.milestones)
        }
        .padding(KiraSpacing.space4)
        .kiraCard(cornerRadius: KiraRadius.large)
    }

    private func milestones(_ values: [BudgetGoalMilestone]) -> some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, milestone in
                HStack(spacing: KiraSpacing.space2) {
                    Image(systemName: milestone.reached ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(milestone.reached ? .pandan : .inkMuted)
                    Text(milestone.label).font(.caption).foregroundStyle(.inkMuted)
                    Spacer(minLength: KiraSpacing.space2)
                    KiraAmount(Decimal(milestone.amount), size: .small)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}
