/**
 Per Kategori (board Budget): each category's row with "Rp1.380.000,00 dari Rp1.800.000,00", its bar,
 and a tag when it has one (Sisa at 90%, Lunas for a paid Tagihan), then each goal post (Dana
 Darurat from Rencana) as a row tagged Pos Tujuan. "masih aman, kok" sits beside the title while no
 category has gone past its plan.
 */
import Domain
import SwiftUI

struct BudgetCategoryList: View {
    let budget: BudgetOverview

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            KiraSectionTitle("budget.categories", trailing: budget.isWithinPlan ? .note("budget.categories.note") : .none)
            KiraListGroup {
                ForEach(budget.allocations, id: \.category) { allocation in
                    BudgetCategoryRow(allocation: allocation)
                }
                ForEach(budget.goalPosts, id: \.name) { goal in
                    BudgetGoalRow(goal: goal, since: budget.period.start)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text("budget.categories.label"))
        }
    }
}

private struct BudgetCategoryRow: View {
    let allocation: BudgetAllocation

    var body: some View {
        KiraListRow(Text(allocation.category.title), leading: .category(allocation.category.tile), trailing: .none) {
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                KiraProgressRibbon(value: Double(allocation.spent), target: Double(allocation.amount))
                    .tone(allocation.isPaidBill ? .healthy : .pandan)
                switch allocation.rowTag {
                case .left(let amount):
                    KiraTag("budget.category.left \(amount.rupiah, format: .rupiah)", tone: .turmeric, icon: .clock)
                case .paid:
                    KiraTag("budget.category.paid", tone: .healthy, icon: .check)
                case nil:
                    EmptyView()
                }
            }
        }
        .subtitle(
            Text("budget.category.of \(allocation.spent.rupiah, format: .rupiah) \(allocation.amount.rupiah, format: .rupiah)")
        )
    }
}

private struct BudgetGoalRow: View {
    let goal: BudgetGoalPost
    let since: CalendarDay

    var body: some View {
        KiraListRow(Text(goal.name), leading: .category(.emergency), trailing: .none) {
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                KiraProgressRibbon(value: Double(goal.currentAmount), target: Double(goal.targetAmount))
                KiraTag("budget.goal.tag", tone: .pandan, icon: .target)
            }
        }
        .subtitle(
            Text("budget.goal.setAside \(goal.currentAmount.rupiah, format: .rupiah) \(since.date.formatted(.kiraDate))")
        )
    }
}
