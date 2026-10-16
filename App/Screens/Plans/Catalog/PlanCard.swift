/** One plan's card on Paket Kira (`article` on the boards). */
import Domain
import SwiftUI

struct PlanCard<Features: View>: View {
    private let terms: PlanTerms
    private let period: BillingPeriod
    private let isCurrent: Bool
    private let features: Features
    private var onDetail: (() -> Void)?

    init(terms: PlanTerms, period: BillingPeriod, isCurrent: Bool, @ViewBuilder features: () -> Features) {
        self.terms = terms
        self.period = period
        self.isCurrent = isCurrent
        self.features = features()
    }

    var body: some View {
        if let onDetail {
            Button(action: onDetail) { card }.buttonStyle(.plain)
        } else {
            card
        }
    }

    /** The same card, opening the plan's details ("Lihat Detail"). */
    func onDetail(_ action: @escaping () -> Void) -> Self {
        var card = self
        card.onDetail = action
        return card
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: KiraSpacing.space3) {
                heading.frame(maxWidth: .infinity, alignment: .leading)
                tag
            }
            VStack(alignment: .leading, spacing: 10) { features }
                .padding(.top, 14)
                .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
            if onDetail != nil { detailLink }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, KiraSpacing.space4)
        .background(.surfaceRaised, in: RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous)
                .strokeBorder(isCurrent ? Color.pandan : .hairline, lineWidth: isCurrent ? 1.5 : 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space1) {
            Text(terms.id.title).kiraFont(.title).foregroundStyle(.ink)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                KiraAmount(Decimal(shownPrice))
                Text(priceUnit).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            if terms.id != .free && period == .yearly {
                Text("plans.yearly.months \(terms.yearlyPaidMonths)")
                    .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                KiraTag(
                    "plans.yearly.saving \(Decimal(terms.yearlySaving), format: .rupiah)", tone: .pandan, icon: .percent
                )
                .padding(.top, KiraSpacing.space1)
            }
            if terms.id == .young {
                KiraHandNote("plans.young.note", size: .small, tilt: -1).padding(.top, KiraSpacing.space1)
            }
        }
    }

    @ViewBuilder private var tag: some View {
        if isCurrent {
            KiraTag("plans.current", tone: .pandan, icon: .check)
        } else if terms.id == .plus {
            KiraTag("plans.plus.tag", tone: .turmeric, icon: .star)
        }
    }

    private var shownPrice: Int { terms.id == .free ? 0 : terms.price(for: period) }

    private var priceUnit: LocalizedStringResource {
        if terms.id == .free { return "plans.price.forever" }
        return period == .monthly ? "plans.price.perMonth" : "plans.price.perYear"
    }

    private var detailLink: some View {
        HStack {
            Text("plans.detail.link").font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
            Spacer(minLength: 0)
            KiraIcon(.chevronRight, size: 18)
        }
        .foregroundStyle(.pandan)
        .padding(.top, KiraSpacing.space3)
        .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
    }
}
