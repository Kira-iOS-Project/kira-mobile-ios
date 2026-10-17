/**
 Hasil Simulasi · Pendidikan Anak (REN-04d, board HasilTujuanPendidikan): the shared result blocks in
 the board's order, with Rincian Biaya after Supaya Tercapai: Pilih Tipe Target (which sets the
 target the whole result weighs), each stage's inflated cost and its parts, and the first stage's
 monthly fees against the parents' income. The plan compounds yearly, as the board does.
 */
import Domain
import Features
import SwiftUI

struct EducationGoalResultScreen: View {
    let outcome: EducationGoalOutcome
    let onOpen: (AppRoute) -> Void
    /** Jadikan Pos Budget: the caller saves the goal (POST /goals) and goes back to Rencana. */
    var onBudget: () -> Void = {}
    /** Ubah Angka, with the recommendation chosen under Supaya Tercapai, if any; then back to the form. */
    var onEdit: (GoalRecommendation?) -> Void = { _ in }
    @State private var targetKind = EducationTarget.all
    @State private var chosen: GoalRecommendation?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.goalSaveLabel) private var saveLabel

    var body: some View {
        let content = EducationResultCopy(outcome: outcome, targetKind: targetKind).content
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "plan.result.title", subtitle: "plan.education.title",
                    leading: .back("plan.result.back") { dismiss() }
                ) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                GoalResultHero(content: content)
                GoalResultStatus(fit: content.projection.fit)
                KiraSectionTitle("plan.result.details", trailing: .note("plan.result.details.note"))
                    .padding(.top, KiraSpacing.space2)
                EducationResultDetails(content: content, lastStage: outcome.plan.levels.last?.stage)
                GoalComposition(projection: content.projection)
                if content.projection.fit != .fits, !content.recommendations.isEmpty {
                    GoalRecommendations(content: content, chosen: $chosen)
                }
                EducationCostBreakdown(outcome: outcome, targetKind: $targetKind)
                GoalAssetClasses(classes: content.assetClasses)
                KiraNotice(.education, title: "plan.result.education.title", message: "plan.result.education")
                GoalFormulas(formulas: content.formulas, footnote: content.footnote)
                KiraNotice(.simulation, title: "plan.goal.simulation.title", message: "plan.result.simulation")
                buttons.padding(.top, KiraSpacing.space1)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.vertical, KiraSpacing.space2)
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }

    /** Ubah Angka at 1 beside Jadikan Pos Budget at 1.3. */
    private var buttons: some View {
        WeightedRow(weights: [1, 1.3], spacing: 10) {
            KiraButton("plan.result.edit", variant: .secondary, size: .small) {
                onEdit(chosen)
                dismiss()
            }
            .block()
            KiraButton(saveLabel, size: .small, action: onBudget).block()
        }
    }
}

/** What the shared blocks show for a Pendidikan plan against the chosen target. */
private struct EducationResultCopy {
    let outcome: EducationGoalOutcome
    let targetKind: EducationTarget

    var content: GoalResultContent {
        let plan = outcome.plan
        let projection = plan.projection(for: targetKind)
        return GoalResultContent(
            goal: "plan.education.title", overline: "plan.education.result.overline \(outcome.childName)",
            amountSize: .large, caption: caption, projection: projection, present: plan.present,
            deposit: plan.deposit, annualReturn: plan.annualReturn ?? 0, horizon: .years(plan.yearsInvesting),
            recommendations: plan.recommendations(for: targetKind),
            assetClasses: GoalMath.assetClasses(years: Double(plan.yearsInvesting)),
            formulas: [costFormula, resultFormula(projection)], footnote: "plan.education.result.footnote")
    }

    /** "SD / MI sampai S1 / D4, mulai 3 tahun lagi". */
    private var caption: Text {
        let plan = outcome.plan
        let first = plan.levels.first?.stage ?? .primary
        let last = plan.levels.last?.stage ?? .bachelor
        let startsIn = max(first.entryAge - plan.childAge, 0)
        let from = EducationCopy.text(first.title)
        let until = EducationCopy.text(last.title)
        return Text("plan.education.result.caption \(from) \(until) \(startsIn)")
    }

    private var costFormula: GoalFormula {
        let inflation = Text(outcome.plan.inflation * 100, format: .kiraMultiple)
        return GoalFormula(
            title: "plan.education.formula.cost",
            lines: [Text("plan.education.formula.cost.line \(inflation)"), Text("plan.education.formula.cost.until")])
    }

    private func resultFormula(_ projection: GoalProjection) -> GoalFormula {
        let plan = outcome.plan
        let rate = Text((plan.annualReturn ?? 0) * 100, format: .kiraMultiple)
        let yearly = Text((plan.deposit * 12).rupiah, format: .rupiah)
        return GoalFormula(
            title: "plan.formula.result",
            lines: [
                Text("plan.education.formula.fv \(rate) \(plan.yearsInvesting) \(yearly)"),
                Text("plan.education.formula.fv.present \(Text(plan.present.rupiah, format: .rupiah))"),
                Text("plan.formula.equals \(Text(projection.result.rupiah, format: .rupiah))"),
            ])
    }
}
