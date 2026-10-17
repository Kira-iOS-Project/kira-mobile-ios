/**
 Budget per Kategori (KIR-38, board Budget): the period in the bar with the back button and the help
 button, the hero, Per Kategori, the footnote that the period follows payday, and Atur Budget.
 */
import Domain
import Features
import SwiftUI

struct BudgetOverviewContent: View {
    let budget: BudgetOverview
    let onOpen: (AppRoute) -> Void
    @State private var isMasked = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space5) {
                KiraNavBar("budget.title", subtitle: period, leading: .back("budget.back") { dismiss() }) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                BudgetHero(budget: budget, isMasked: $isMasked)
                if budget.isConfigured {
                    BudgetCategoryList(budget: budget)
                } else {
                    KiraNotice(.info, title: "budget.setup.title", message: "budget.setup.body")
                }
                Text("budget.footnote")
                    .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                KiraButton("budget.edit") { onOpen(.editBudget) }.icon(.settings).block()
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space8)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 54, y: -28)
            }
        }
        .kiraScrollEdges()
    }

    /** "Periode 25 September – 24 Oktober 2026": the year once, as in Catat. */
    private var period: LocalizedStringResource {
        let start = budget.period.start.date.formatted(.kiraDayMonth)
        return "budget.period \(start) \(budget.period.end.date.formatted(.kiraDate))"
    }
}

extension BudgetOverview {
    /** The shape the screen shows while the budget loads, redacted. */
    static let placeholder = BudgetOverview(
        income: 0, payday: Payday(day: Payday.defaultDay),
        period: PayPeriod(
            start: CalendarDay(year: 2026, month: 10, day: 25),
            end: CalendarDay(year: 2026, month: 11, day: 24), daysUntilPayday: 0),
        allocations: [.init(category: .food, amount: 0)])
}
