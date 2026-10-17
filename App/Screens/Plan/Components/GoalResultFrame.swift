/**
 The frame of every Hasil Simulasi board (HasilTujuanDP … HasilTujuanLainnya, REN-04c to REN-04i):
 "Hasil Simulasi" with the goal as subtitle, back to the form and help to Kira Peduli; the hero with
 the target and how far the strategy gets; the status; Rinciannya; Dari Mana Hasilnya?; Supaya
 Tercapai while the strategy falls short, whose choice Ubah Angka takes back to the form; the asset
 classes for the horizon; the two notices and the working; then Ubah Angka beside Jadikan Pos Budget.
 */
import Domain
import SwiftUI

struct GoalResultFrame<Extra: View>: View {
    let content: GoalResultContent
    var isSaving = false
    /** Ubah Angka, with the recommendation chosen under Supaya Tercapai, if any. */
    let onEdit: (GoalRecommendation?) -> Void
    /** Jadikan Pos Budget. */
    let onBudget: () -> Void
    let onHelp: () -> Void
    /** What a kind adds after Dari Mana Hasilnya? (DP Rumah's Simulasi KPR). */
    @ViewBuilder var extra: Extra
    @State private var chosen: GoalRecommendation?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "plan.result.title", subtitle: content.goal, leading: .back("plan.result.back") { dismiss() }
                ) {
                    KiraHelpButton(.icon, action: onHelp)
                }
                GoalResultHero(content: content)
                GoalResultStatus(fit: content.projection.fit)
                KiraSectionTitle("plan.result.details", trailing: .note("plan.result.details.note"))
                    .padding(.top, KiraSpacing.space2)
                GoalResultDetails(content: content)
                GoalComposition(projection: content.projection)
                extra
                if content.projection.fit != .fits, !content.recommendations.isEmpty {
                    GoalRecommendations(content: content, chosen: $chosen)
                }
                GoalAssetClasses(classes: content.assetClasses, title: content.assetsTitle, note: content.assetsNote)
                KiraNotice(.education, title: "plan.result.education.title", message: "plan.result.education")
                GoalFormulas(formulas: content.formulas, footnote: content.footnote, opens: content.opensFormulas)
                KiraNotice(.simulation, title: "plan.goal.simulation.title", message: "plan.result.simulation")
                GoalResultButtons(isSaving: isSaving, onEdit: { onEdit(chosen) }, onBudget: onBudget)
                    .padding(.top, KiraSpacing.space1)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space2)
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }
}

extension GoalResultFrame where Extra == EmptyView {
    /** A result with nothing of its kind's own. */
    init(
        content: GoalResultContent, isSaving: Bool = false, onEdit: @escaping (GoalRecommendation?) -> Void,
        onBudget: @escaping () -> Void, onHelp: @escaping () -> Void
    ) {
        self.init(content: content, isSaving: isSaving, onEdit: onEdit, onBudget: onBudget, onHelp: onHelp) {
            EmptyView()
        }
    }
}

/** Ubah Angka at 1 beside Jadikan Pos Budget at 1.3; stacked, primary on top, at the accessibility sizes. */
private struct GoalResultButtons: View {
    let isSaving: Bool
    let onEdit: () -> Void
    let onBudget: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.goalSaveLabel) private var saveLabel

    var body: some View {
        let edit = KiraButton("plan.result.edit", variant: .secondary, size: .small, action: onEdit).block()
        let budget = KiraButton(saveLabel, size: .small, action: onBudget).block().disabled(isSaving)
        if typeSize.isAccessibilitySize {
            VStack(spacing: KiraSpacing.space2) {
                budget
                edit
            }
        } else {
            WeightedRow(weights: [1, 1.3], spacing: 10) {
                edit
                budget
            }
        }
    }
}
