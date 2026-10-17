/** The loaded budget overview: period, income, allocation warning and category usage. */
import Domain
import SwiftUI

struct BudgetOverviewContent: View {
    let budget: BudgetOverview
    let onEdit: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("budget.title", subtitle: period, isLarge: true)
                KiraButton("budget.edit", variant: .secondary, size: .small, action: onEdit)
                summary
                if budget.isConfigured {
                    if budget.isOverallocated { BudgetOverallocationNotice() }
                    BudgetCategoryList(allocations: budget.allocations)
                    if !budget.goalPosts.isEmpty { BudgetGoalPostList(goals: budget.goalPosts) }
                } else {
                    KiraNotice(.info, title: "budget.setup.title", message: "budget.setup.body")
                }
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space3)
            .padding(.bottom, KiraSpacing.space8)
        }
        .kiraScrollEdges()
    }

    private var period: LocalizedStringResource {
        "budget.period \(budget.period.start.date.formatted(.kiraDate)) \(budget.period.end.date.formatted(.kiraDate))"
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            summaryRow("budget.income", amount: budget.income)
            summaryRow("budget.remaining", amount: budget.remaining)
            summaryRow("budget.allocated", amount: budget.allocated)
            summaryRow("budget.spent", amount: budget.spent)
        }
        .padding(KiraSpacing.space4)
        .kiraCard(cornerRadius: KiraRadius.large)
    }

    private func summaryRow(_ title: LocalizedStringResource, amount: Int) -> some View {
        HStack {
            Text(title).font(.subheadline).foregroundStyle(.inkMuted)
            Spacer(minLength: KiraSpacing.space2)
            KiraAmount(Decimal(amount), size: .small)
        }
        .accessibilityElement(children: .combine)
    }
}

extension BudgetOverview {
    static let placeholder = BudgetOverview(
        income: 0, payday: Payday(day: Payday.defaultDay),
        period: PayPeriod(
            start: CalendarDay(year: 2026, month: 10, day: 25),
            end: CalendarDay(year: 2026, month: 11, day: 24), daysUntilPayday: 0),
        allocations: [.init(category: .food, amount: 0)])
}
