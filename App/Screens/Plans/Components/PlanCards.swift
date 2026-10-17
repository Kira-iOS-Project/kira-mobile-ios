/**
 The three plan cards of Paket Kira: Kira Gratis, then Kira Muda and Kira Plus, which open their
 details. The person's plan has the pandan border and "Paketmu"; yearly prices say how many months
 they pay for and what they save, as a real amount, never a struck-through price.
 */
import Domain
import SwiftUI

struct PlanCards: View {
    let catalog: PlanCatalog
    let period: BillingPeriod
    let onDetail: (PlanTerms) -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space3) {
            if let free = catalog.terms(for: .free) {
                PlanCard(terms: free, period: period, isCurrent: catalog.current.plan == .free) {
                    PlanFeature("plans.free.feature.core")
                    PlanFeature("plans.free.feature.tools")
                    PlanFeature("plans.free.feature.care")
                    PlanFeature("plans.feature.quota \(free.aiMessages) \(free.receipts)")
                }
            }
            if let young = catalog.terms(for: .young) {
                PlanCard(terms: young, period: period, isCurrent: catalog.current.plan == .young) {
                    PlanFeature("plans.young.feature.free")
                    PlanFeature("plans.feature.quota \(young.aiMessages) \(young.receipts)")
                    PlanFeature("plans.young.feature.summary")
                }
                .onDetail { onDetail(young) }
            }
            if let plus = catalog.terms(for: .plus) {
                PlanCard(terms: plus, period: period, isCurrent: catalog.current.plan == .plus) {
                    PlanFeature("plans.plus.feature.young")
                    PlanFeature("plans.feature.quota \(plus.aiMessages) \(plus.receipts)")
                    PlanFeature("plans.plus.feature.voice")
                    PlanFeature("plans.plus.feature.score")
                    PlanFeature("plans.plus.feature.portfolio")
                }
                .onDetail { onDetail(plus) }
            }
        }
    }
}

/** One line of a card's list, after a pandan check. */
struct PlanFeature: View {
    private let text: LocalizedStringResource

    init(_ text: LocalizedStringResource) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            KiraIcon(.check, size: 16, weight: .bold).foregroundStyle(.pandan)
            Text(text).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
