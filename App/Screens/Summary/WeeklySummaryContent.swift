import Domain
import Features
import SwiftUI

/** The loaded weekly totals, comparison, chart, largest categories, and server note. */
struct WeeklySummaryContent: View {
    let summary: WeeklySummary
    let model: WeeklySummaryModel
    let onOpenHistory: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            Text("weekly.period \(DayRange(first: summary.weekStart, last: summary.weekEnd).formatted(.kiraDayRange))")
                .font(.footnote.weight(.medium)).foregroundStyle(.inkMuted)
            KiraMascot(.calm, size: 112).frame(maxWidth: .infinity).accessibilityHidden(true)
            totals
            comparison
            chart
            categories
            if let note = summary.note { noteCard(note) }
            KiraButton("weekly.history", variant: .secondary, action: onOpenHistory).block()
        }
    }

    private var totals: some View {
        KiraListGroup("weekly.totals") {
            KiraListRow(Text("weekly.expense"))
                .amount(KiraAmount(Decimal(summary.totals.expense), size: .small))
            KiraListRow(Text("weekly.income"))
                .amount(KiraAmount(Decimal(summary.totals.income), size: .small))
            KiraListRow(Text("weekly.net"))
                .amount(KiraAmount(Decimal(summary.totals.net), size: .small).signed())
        }
    }

    private var comparison: some View {
        Group {
            if summary.spendingUnchanged {
                KiraTag("weekly.comparison.same", tone: .neutral)
            } else if summary.spendingIncreased {
                KiraTag("weekly.comparison.more \(localized(summary.expenseDifference))", tone: .neutral)
            } else {
                KiraTag("weekly.comparison.less \(localized(summary.expenseDifference))", tone: .neutral)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var chart: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            KiraSectionTitle("weekly.chart.title")
            KiraBars(
                "weekly.chart.accessibility",
                columns: model.chartDays.map { day in
                    KiraBars.Column(
                        label: weekdayLabel(day.weekday), value: Double(day.expense),
                        isHighlighted: day.index == model.highlightedChartIndex)
                }
            )
            .padding(KiraSpacing.space4)
            .kiraCard()
        }
    }

    private var categories: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            KiraSectionTitle("weekly.categories")
            if summary.topCategories.isEmpty {
                Text("weekly.categories.empty")
                    .font(.footnote).foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1)
            } else {
                KiraListGroup {
                    ForEach(summary.topCategories) { row in
                        KiraListRow(Text(categoryName(row.category)), leading: .category(tile(for: row.category)))
                            .amount(KiraAmount(Decimal(row.amount), size: .small))
                    }
                }
            }
        }
    }

    private func noteCard(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            KiraNotice(.aiText, title: "weekly.note.label")
            Text(note)
                .font(.body).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                .padding(.horizontal, KiraSpacing.space4).padding(.vertical, KiraSpacing.space3)
                .frame(maxWidth: .infinity, alignment: .leading).kiraCard()
        }
    }

    private func localized(_ amount: Int) -> String {
        amount.formatted(.number.locale(Locale(identifier: "id_ID")))
    }

    private func weekdayLabel(_ weekday: WeeklySummaryModel.Weekday) -> LocalizedStringResource {
        switch weekday {
        case .sunday: "weekly.day.sunday"
        case .monday: "weekly.day.monday"
        case .tuesday: "weekly.day.tuesday"
        case .wednesday: "weekly.day.wednesday"
        case .thursday: "weekly.day.thursday"
        case .friday: "weekly.day.friday"
        case .saturday: "weekly.day.saturday"
        }
    }

    private func tile(for key: String) -> KiraCategory {
        TransactionCategory(rawValue: key)?.tile ?? .other
    }

    private func categoryName(_ key: String) -> LocalizedStringResource {
        switch TransactionCategory(rawValue: key) {
        case .food: "ledger.category.food"
        case .coffee: "ledger.category.coffee"
        case .transport: "ledger.category.transport"
        case .shopping: "ledger.category.shopping"
        case .bills: "ledger.category.bills"
        case .paylaterInstalment: "ledger.category.paylaterInstalment"
        case .savingsDeposit: "ledger.category.savingsDeposit"
        case .insurance: "ledger.category.insurance"
        case .entertainment: "ledger.category.entertainment"
        case .health: "ledger.category.health"
        case .education: "ledger.category.education"
        case .household: "ledger.category.household"
        case .otherExpense, .otherIncome, nil: "ledger.category.other"
        case .salary: "ledger.category.salary"
        case .bonus: "ledger.category.bonus"
        case .business: "ledger.category.business"
        }
    }
}
