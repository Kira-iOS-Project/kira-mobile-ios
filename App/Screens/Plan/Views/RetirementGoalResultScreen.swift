/**
 Hasil Simulasi · Dana Pensiun (REN-04f, board HasilTujuanPensiun): 25 times a year of expenses on
 retirement day (the 4% rule), inflated, against what the strategy reaches, in the frame every
 result shares. Supaya Tercapai offers a higher deposit or return, never more time: the date is an age.
 */
import Domain
import Features
import SwiftUI

struct RetirementGoalResultScreen: View {
    let outcome: RetirementGoalOutcome
    let onOpen: (AppRoute) -> Void
    /** Jadikan Pos Budget: the caller saves the goal (POST /goals) and goes back to Rencana. */
    var onBudget: () -> Void = {}
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GoalResultFrame(
            content: content, onEdit: { _ in dismiss() }, onBudget: onBudget, onHelp: { onOpen(.care) })
    }

    private var content: GoalResultContent {
        GoalResultContent(
            goal: "plan.retirement.title", overline: "plan.retirement.result.overline", amountSize: .large,
            caption: Text(
                "plan.retirement.caption \(outcome.years) \(Text(outcome.inflation * 100, format: .kiraMultiple))"),
            projection: outcome.projection, present: outcome.present, deposit: outcome.deposit,
            annualReturn: outcome.annualReturn, horizon: .years(outcome.years),
            recommendations: outcome.recommendations, assetClasses: outcome.assetClasses,
            formulas: [expense, target, result], footnote: "plan.retirement.footnote")
    }

    /** Pengeluaran tahunan saat pensiun: a year today × (1 + inflation)^years. */
    private var expense: GoalFormula {
        let inflation = Text(outcome.inflation * 100, format: .kiraMultiple)
        return GoalFormula(
            title: "plan.retirement.formula.expense",
            lines: [
                Text((outcome.monthlyExpense * 12).rupiah, format: .rupiah),
                Text("plan.formula.inflate.years \(inflation) \(outcome.years)"),
                Text("plan.formula.equals \(Text(outcome.annualExpense.rupiah, format: .rupiah))"),
            ])
    }

    /** Target (aturan 4%): that year ÷ 4%. */
    private var target: GoalFormula {
        GoalFormula(
            title: "plan.retirement.formula.target",
            lines: [
                Text("plan.retirement.formula.withdrawal \(Text(outcome.annualExpense.rupiah, format: .rupiah))"),
                Text("plan.formula.equals \(Text(outcome.projection.target.rupiah, format: .rupiah))"),
            ])
    }

    /** Hasil investasi: FV(return ÷ 12, months, deposit, what is there). */
    private var result: GoalFormula {
        let rate = Text(outcome.annualReturn * 100, format: .kiraMultiple)
        let deposit = Text(outcome.deposit.rupiah, format: .rupiah)
        let present = Text(outcome.present.rupiah, format: .rupiah)
        return GoalFormula(
            title: "plan.formula.result",
            lines: [
                Text("plan.formula.fv.head \(rate) \(outcome.years * 12)"),
                Text("plan.formula.fv.args \(deposit) \(present)"),
                Text("plan.formula.equals \(Text(outcome.projection.result.rupiah, format: .rupiah))"),
            ])
    }
}
