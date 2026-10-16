/**
 Detail Kira Muda and Detail Kira Plus (AKN-06g, AKN-06h; boards PaketMuda, PaketPlus): the price
 a month and a year, what the plan holds, its monthly quotas and Traktir Kira. Coba opens Bayar for
 the period picked on Paket Kira.
 */
import Domain
import Features
import SwiftUI

struct PlanDetailView: View {
    private enum Page: Hashable {
        case checkout
        case treat
    }

    let terms: PlanTerms
    let period: BillingPeriod
    let service: any PlansService
    let onOpen: (AppRoute) -> Void
    @State private var page: Page?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        PlansScreenFrame {
            KiraNavBar(terms.id.title, leading: .back("plans.detail.back") { dismiss() })
            header
            contents
            KiraListGroup("plans.detail.quota") {
                KiraListRow(Text("plans.detail.messages \(terms.aiMessages)"), leading: .icon(.chat))
                    .subtitle(Text("plans.detail.messages.detail"))
                KiraListRow(Text("plans.detail.receipts \(terms.receipts)"), leading: .icon(.receipt))
                    .subtitle(Text("plans.detail.receipts.detail"))
            }
            KiraListGroup("plans.detail.help") {
                KiraListRow(Text("plans.treat.row"), leading: .icon(.gift), action: { page = .treat })
                    .subtitle(Text("plans.detail.treat.detail"))
            }
            KiraNotice(.info, title: "plans.prototype", message: "plans.detail.prototype")
            Spacer(minLength: 0)
            PlansButtonRow(
                secondary: KiraButton("plans.treat.row", variant: .secondary, size: .small) { page = .treat },
                primary: KiraButton(terms.id == .young ? "plans.tryYoung" : "plans.tryPlus", size: .small) {
                    page = .checkout
                })
        }
        .navigationDestination(item: $page) { page in
            switch page {
            case .checkout: CheckoutView(terms: terms, period: period, service: service) { onOpen(.subscription) }
            case .treat: TreatView(service: service)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            PlansDisplayTitle(terms.id.title, size: 28)
            PlanPriceLine {
                KiraAmount(Decimal(terms.monthlyPrice))
                Text("plans.detail.price \(Decimal(terms.yearlyPrice), format: .rupiah)")
                    .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            Text(terms.id == .young ? "plans.detail.young.lede" : "plans.detail.plus.lede")
                .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
        }
        .padding(.horizontal, KiraSpacing.space1)
    }

    @ViewBuilder private var contents: some View {
        KiraListGroup("plans.detail.contents") {
            if terms.id == .young {
                KiraListRow(Text("plans.young.feature.free"), leading: .icon(.check))
                    .subtitle(Text("plans.detail.young.free.detail"))
                KiraListRow(Text("plans.detail.young.summary"), leading: .icon(.chart))
                    .subtitle(Text("plans.detail.young.summary.detail"))
            } else {
                KiraListRow(Text("plans.plus.feature.young"), leading: .icon(.check))
                    .subtitle(Text("plans.detail.plus.young.detail"))
                KiraListRow(Text("plans.detail.plus.voice"), leading: .icon(.mic))
                    .subtitle(Text("plans.detail.plus.voice.detail"))
                KiraListRow(Text("plans.detail.plus.score"), leading: .icon(.chart))
                    .subtitle(Text("plans.detail.plus.score.detail"))
                KiraListRow(Text("plans.plus.feature.portfolio"), leading: .icon(.wallet))
                    .subtitle(Text("plans.detail.plus.portfolio.detail"))
            }
        }
    }
}
