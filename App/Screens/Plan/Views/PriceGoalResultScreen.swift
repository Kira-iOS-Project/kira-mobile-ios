/**
 Hasil Simulasi · Kendaraan (REN-04g, board HasilTujuanKendaraan) and · Barang Impian (REN-04h,
 board HasilTujuanBarang, titled with the thing's name): the DP share of the price inflated over the
 horizon ("Beli tunai" at 100%), against what the strategy reaches, in the frame every result shares.
 */
import Domain
import Features
import SwiftUI

struct PriceGoalResultScreen: View {
    let outcome: PriceGoalOutcome
    let kind: GoalKind
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
            goal: kind == .vehicle ? "plan.vehicle.title" : "plan.goal.named \(outcome.name)",
            overline: "plan.price.result.overline", caption: caption, projection: outcome.projection,
            present: outcome.present, deposit: outcome.deposit, annualReturn: outcome.annualReturn,
            horizon: outcome.horizon == .years ? .years(outcome.months / 12) : .months(outcome.months),
            recommendations: outcome.recommendations, assetClasses: outcome.assetClasses,
            formulas: [target, GoalWorking.result(outcome.projection, outcome: outcome)])
    }

    private var caption: Text {
        let inflation = Text(outcome.inflation * 100, format: .kiraMultiple)
        let share = Text(outcome.downPayment * 100, format: .kiraMultiple)
        let cash = outcome.downPayment >= 1
        switch (kind == .vehicle, cash) {
        case (true, true): return Text("plan.vehicle.caption.cash \(outcome.months / 12) \(inflation)")
        case (true, false): return Text("plan.vehicle.caption.dp \(share) \(outcome.months / 12) \(inflation)")
        case (false, true): return Text("plan.goods.caption.cash \(outcome.months) \(inflation)")
        case (false, false): return Text("plan.goods.caption.dp \(share) \(outcome.months) \(inflation)")
        }
    }

    /** Target: price × DP × (1 + inflation)^horizon. */
    private var target: GoalFormula {
        let inflation = Text(outcome.inflation * 100, format: .kiraMultiple)
        let share = Text(outcome.downPayment * 100, format: .kiraMultiple)
        let growth =
            outcome.horizon == .years
            ? Text("plan.formula.inflate.years \(inflation) \(outcome.months / 12)")
            : Text("plan.formula.inflate.months \(inflation) \(outcome.months)")
        return GoalFormula(
            title: "plan.formula.target",
            lines: [
                Text("plan.formula.share \(Text(outcome.price.rupiah, format: .rupiah)) \(share)"),
                growth,
                Text("plan.formula.equals \(Text(outcome.projection.target.rupiah, format: .rupiah))"),
            ])
    }
}

/** The working the results share. */
enum GoalWorking {
    private static func rupiah(_ value: Int) -> Text { Text(value.rupiah, format: .rupiah) }

    /** Hasil investasi: FV(return ÷ 12, months, deposit, what is there) = result. */
    static func result(_ projection: GoalProjection, outcome: PriceGoalOutcome) -> GoalFormula {
        result(
            projection, annualReturn: outcome.annualReturn, months: outcome.months, deposit: outcome.deposit,
            present: outcome.present)
    }

    static func result(
        _ projection: GoalProjection, annualReturn: Double, months: Int, deposit: Int, present: Int
    ) -> GoalFormula {
        GoalFormula(
            title: "plan.formula.result",
            lines: [
                Text("plan.formula.fv.head \(Text(annualReturn * 100, format: .kiraMultiple)) \(months)"),
                Text("plan.formula.fv.args \(rupiah(deposit)) \(rupiah(present))"),
                Text("plan.formula.equals \(Text(projection.result.rupiah, format: .rupiah))"),
            ])
    }
}
