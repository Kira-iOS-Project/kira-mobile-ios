/**
 Hasil Simulasi · Lainnya (REN-04i, board HasilTujuanLainnya, titled with the goal's name): the
 amount the person set, never inflated, against what the strategy reaches, deposited monthly or
 yearly at the start or end of each, in the frame every result shares.
 */
import Domain
import Features
import SwiftUI

struct OtherGoalResultScreen: View {
    let outcome: OtherGoalOutcome
    let onOpen: (AppRoute) -> Void
    /** Jadikan Pos Budget: the caller saves the goal (POST /goals) and goes back to Rencana. */
    var onBudget: () -> Void = {}
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GoalResultFrame(
            content: content, onEdit: { _ in dismiss() }, onBudget: onBudget, onHelp: { onOpen(.care) })
    }

    private var content: GoalResultContent {
        let projection = outcome.projection
        return GoalResultContent(
            goal: "plan.goal.named \(outcome.name)", overline: "plan.other.result.overline",
            caption: Text("plan.other.caption \(outcome.name) \(outcome.years)"), projection: projection,
            present: outcome.present, deposit: outcome.deposit, period: outcome.period,
            annualReturn: outcome.annualReturn, horizon: .years(outcome.years),
            recommendations: outcome.recommendations, assetClasses: outcome.assetClasses,
            formulas: [
                GoalFormula(
                    title: "plan.formula.target",
                    lines: [
                        Text(projection.target.rupiah, format: .rupiah), Text("plan.other.formula.noInflation"),
                    ]),
                result,
            ],
            footnote: footnote)
    }

    /** FV(return ÷ periods per year, periods, deposit, what is there, start or end of period). */
    private var result: GoalFormula {
        let rate = Text(outcome.annualReturn * 100, format: .kiraMultiple)
        let deposit = Text(outcome.deposit.rupiah, format: .rupiah)
        let present = Text(outcome.present.rupiah, format: .rupiah)
        let head =
            outcome.period == .month
            ? Text("plan.formula.fv.head \(rate) \(outcome.years * 12)")
            : Text("plan.other.formula.fv.yearly \(rate) \(outcome.years)")
        let args =
            outcome.timing == .start
            ? Text("plan.other.formula.fv.start \(deposit) \(present)")
            : Text("plan.other.formula.fv.end \(deposit) \(present)")
        return GoalFormula(
            title: "plan.formula.result",
            lines: [head, args, Text("plan.formula.equals \(Text(outcome.projection.result.rupiah, format: .rupiah))")])
    }

    private var footnote: LocalizedStringResource {
        switch (outcome.period, outcome.timing) {
        case (.month, .start): "plan.result.footnote"
        case (.month, .end): "plan.other.footnote.monthEnd"
        case (.year, .start): "plan.other.footnote.yearStart"
        case (.year, .end): "plan.other.footnote.yearEnd"
        }
    }
}
