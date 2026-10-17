/** Planned categories and their spending in the active pay period. */
import Domain
import SwiftUI

struct BudgetCategoryList: View {
    let allocations: [BudgetAllocation]

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            KiraSectionTitle("budget.categories")
            if allocations.isEmpty {
                Text("budget.categories.empty")
                    .font(.subheadline).foregroundStyle(.inkMuted)
                    .padding(KiraSpacing.space4).frame(maxWidth: .infinity, alignment: .leading)
                    .kiraCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(allocations.enumerated()), id: \.offset) { index, allocation in
                        BudgetCategoryRow(allocation: allocation)
                        if index < allocations.count - 1 { Rectangle().fill(.line).frame(height: 1) }
                    }
                }
                .padding(.horizontal, KiraSpacing.space4)
                .kiraCard()
            }
        }
    }
}

private struct BudgetCategoryRow: View {
    let allocation: BudgetAllocation

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            HStack(alignment: .top, spacing: KiraSpacing.space3) {
                KiraCategoryIcon(allocation.category.tile, size: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text(allocation.category.title).font(.subheadline.weight(.semibold)).foregroundStyle(.ink)
                    Text("budget.category.spent")
                        .font(.caption).foregroundStyle(.inkMuted)
                    KiraAmount(Decimal(allocation.spent), size: .small)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("budget.category.allocation").font(.caption).foregroundStyle(.inkMuted)
                    KiraAmount(Decimal(allocation.amount), size: .small)
                    if allocation.isNearLimit { KiraTag("budget.category.nearLimit", tone: .turmeric) }
                }
            }
            KiraProgressRibbon(
                value: Double(allocation.spent), target: Double(max(allocation.amount, 1)),
                label: allocation.category.title
            ).tone(allocation.isNearLimit ? .turmeric : .pandan)
        }
        .padding(.vertical, KiraSpacing.space3)
        .accessibilityElement(children: .contain)
    }
}
