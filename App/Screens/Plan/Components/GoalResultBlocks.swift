/**
 The top half every Hasil Simulasi board shares: the hero (target, line, and how far the result
 gets), the status card, Rinciannya, and Dari Mana Hasilnya? (pokok against imbal hasil).
 */
import Domain
import Features
import SwiftUI

/** The hero: the overline, the target, the kind's line, and "Hasil investasi · N% dari target". */
struct GoalResultHero: View {
    let content: GoalResultContent

    var body: some View {
        let projection = content.projection
        VStack(alignment: .leading, spacing: 6) {
            Text(content.overline).kiraFont(.overline).foregroundStyle(.onHeroMuted)
            KiraAmount(projection.target.rupiah, size: content.amountSize).inverse()
            content.caption.font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.onHeroMuted)
            KiraProgressRibbon(
                value: Double(projection.result), target: Double(projection.target), label: "plan.result.ribbon",
                valueLabel: "plan.result.ribbon.share \(min(projection.share, 1), format: .percent.precision(.fractionLength(0)))"
            )
            .inverse()
            .padding(.top, KiraSpacing.space3)
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 22, trailing: 20))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .bottom) { KiraScenery(tone: .hero, height: 92).accessibilityHidden(true) }
        .background(.hero)
        .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

/** The status card: the fit's tag and sentence. */
struct GoalResultStatus: View {
    let fit: GoalFit

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            KiraTag(fit.tag, tone: fit.tone, icon: fit.icon)
            Text(fit.sentence).font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.ink)
        }
        .padding(KiraSpacing.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }
}

/** Rinciannya: what is there, the deposit, the return, the horizon, the result, and what is short. */
struct GoalResultDetails: View {
    let content: GoalResultContent

    var body: some View {
        let projection = content.projection
        KiraListGroup("plan.result.details.group") {
            KiraListRow(Text("plan.result.present"), leading: .icon(.wallet), trailing: .none)
                .amount(KiraAmount(content.present.rupiah))
            KiraListRow(Text(content.period.depositTitle), leading: .icon(.calendar), trailing: .none)
                .amount(KiraAmount(content.deposit.rupiah))
            KiraListRow(Text("plan.result.return"), leading: .icon(.chart), trailing: .none)
                .subtitle(GoalCopy.yearlyRate(content.annualReturn))
            KiraListRow(Text("plan.result.horizon"), leading: .icon(.clock), trailing: .none)
                .subtitle(content.horizon.text)
            KiraListRow(Text("plan.result.outcome"), leading: .icon(.target), trailing: .none)
                .subtitle(Text("plan.result.outcome.subtitle")).amount(KiraAmount(projection.result.rupiah))
            if projection.shortfall > 0 {
                KiraListRow(Text("plan.result.shortfall"), leading: .icon(.alert), trailing: .none)
                    .subtitle(Text("plan.result.shortfall.subtitle"))
                    .amount(KiraAmount(projection.shortfall.rupiah))
            }
        }
    }
}

/** Dari Mana Hasilnya?: a bar of pokok against imbal hasil, and each amount with its share. */
struct GoalComposition: View {
    let projection: GoalProjection

    var body: some View {
        let parts = GoalShares(principal: projection.principal, growth: projection.growth)
        VStack(alignment: .leading, spacing: 10) {
            Text("plan.result.composition").font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                .foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
            GeometryReader { bar in
                HStack(spacing: 3) {
                    UnevenRoundedRectangle(topLeadingRadius: 6, bottomLeadingRadius: 6, bottomTrailingRadius: 3, topTrailingRadius: 3)
                        .fill(.pandan).frame(width: max(bar.size.width - 3, 0) * parts.principalShare)
                    UnevenRoundedRectangle(topLeadingRadius: 3, bottomLeadingRadius: 3, bottomTrailingRadius: 6, topTrailingRadius: 6)
                        .fill(.artTurmeric)
                }
            }
            .frame(height: 12)
            .accessibilityHidden(true)
            WeightedRow(weights: [1, 1], spacing: 10) {
                part("plan.result.principal \(parts.principalPercent)", amount: projection.principal, dot: .pandan)
                part("plan.result.growth \(parts.growthPercent)", amount: projection.growth, dot: .artTurmeric)
            }
        }
        .padding(KiraSpacing.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }

    private func part(_ label: LocalizedStringResource, amount: Int, dot: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Circle().fill(dot).frame(width: 8, height: 8).accessibilityHidden(true)
                Text(label).font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            KiraAmount(amount.rupiah, size: .small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
