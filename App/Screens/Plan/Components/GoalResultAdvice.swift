/**
 The lower half every Hasil Simulasi board shares: Supaya Tercapai (one recommendation to choose
 before Ubah Angka), the asset classes for the horizon (classes, never products), and the working
 in "Gimana Ngitungnya?".
 */
import Domain
import SwiftUI

/** Supaya Tercapai: each way to reach the target, one of which the person may choose. */
struct GoalRecommendations: View {
    let content: GoalResultContent
    @Binding var chosen: GoalRecommendation?

    var body: some View {
        KiraSectionTitle("plan.result.advice").padding(.top, KiraSpacing.space2)
        KiraListGroup("plan.result.advice.group", footer: "plan.result.advice.footer") {
            ForEach(Array(content.recommendations.enumerated()), id: \.offset) { _, recommendation in
                KiraListRow(
                    Text(recommendation.title), leading: .icon(recommendation.icon),
                    trailing: .check(chosen == recommendation)
                ) {
                    chosen = chosen == recommendation ? nil : recommendation
                }
                .subtitle(recommendation.detail(period: content.period))
            }
        }
    }
}

/** Kelas Aset untuk Jangka Ini: the classes as neutral tags, and the note on moving to lower risk. */
struct GoalAssetClasses: View {
    let classes: [GoalAssetClass]

    var body: some View {
        KiraSectionTitle("plan.result.assets").padding(.top, KiraSpacing.space2)
        VStack(alignment: .leading, spacing: 10) {
            KiraFlowRow(spacing: 6) {
                ForEach(classes, id: \.self) { KiraTag($0.title) }
            }
            Text("plan.result.assets.note").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
        }
        .padding(KiraSpacing.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }
}

/** Gimana Ngitungnya?: each working in a bordered box, then the kind's footnote. */
struct GoalFormulas: View {
    let formulas: [GoalFormula]
    let footnote: LocalizedStringResource

    var body: some View {
        KiraAccordion("plan.result.formula.title", subtitle: "plan.result.formula.subtitle", icon: .calculator) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(formulas.enumerated()), id: \.offset) { _, formula in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formula.title).font(.caption.weight(.semibold)).kiraLineHeight(16, size: 12)
                            .foregroundStyle(.inkMuted)
                        ForEach(Array(formula.lines.enumerated()), id: \.offset) { _, line in
                            line.kiraFont(.formula).foregroundStyle(.ink)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .padding(KiraSpacing.space3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .kiraCard(.surface, cornerRadius: KiraRadius.small)
            Text(footnote).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
        }
    }
}
