/**
 REN-04c, Hasil Simulasi · DP Rumah (board HasilTujuanDP): the shared result (the DP when it is due,
 the status, Rinciannya, Dari Mana Hasilnya?) with Simulasi KPR after the composition: the
 instalment's health, the loan's figures and Biaya Lain Saat Beli. Jadikan Pos Budget creates the
 goal and goes back to Rencana; a failure keeps the result and shows Coba Lagi and Tutup.
 */
import Domain
import Features
import SwiftUI

struct HouseDownPaymentResultScreen: View {
    let result: HouseDownPaymentResult
    private let onOpen: (AppRoute) -> Void
    @State private var budget: GoalBudgetModel
    @Environment(\.dismiss) private var dismiss

    init(result: HouseDownPaymentResult, service: any GoalService, onOpen: @escaping (AppRoute) -> Void) {
        self.result = result
        self.onOpen = onOpen
        _budget = State(initialValue: GoalBudgetModel(service: service))
    }

    var body: some View {
        GoalResultFrame(
            content: content, isSaving: budget.isSaving, onEdit: { _ in dismiss() },
            onBudget: { Task { await budget.save(result.draft(today: CalendarDay(.now))) } },
            onHelp: { onOpen(.care) },
            extra: { MortgageSummary(mortgage: result.mortgage) })
        .goalBudgetDialog(budget, draft: result.draft(today: CalendarDay(.now)))
        .onChange(of: budget.saved) { _, saved in
            if saved != nil { onOpen(.plan) }
        }
    }

    private var content: GoalResultContent {
        let goal = result.goal
        let projection = goal.projection
        let downRate = GoalCopy.percent(goal.downPaymentRate)
        let inflation = GoalCopy.percent(goal.inflation)
        return GoalResultContent(
            goal: "plan.dp.goal", overline: "plan.result.overline.total",
            caption: Text("plan.dp.caption \(downRate) \(goal.years) \(inflation)"),
            projection: projection, present: goal.present, deposit: goal.deposit, annualReturn: goal.annualReturn,
            horizon: .years(goal.years), recommendations: goal.recommendations,
            assetClasses: GoalMath.assetClasses(years: Double(goal.years)),
            formulas: [
                GoalFormula(
                    title: "plan.formula.target",
                    lines: [
                        Text("plan.dp.formula.cost \(GoalCopy.rupiah(goal.price)) \(downRate)"),
                        Text("plan.formula.inflation \(inflation) \(goal.years)"),
                        Text("plan.formula.equals \(GoalCopy.rupiah(projection.target))"),
                    ]),
                GoalFormula(
                    title: "plan.formula.result",
                    lines: [
                        Text("plan.formula.fv \(GoalCopy.percent(goal.annualReturn)) \(goal.years * 12)"),
                        Text(
                            "plan.formula.fv.amounts \(GoalCopy.rupiah(goal.deposit)) \(GoalCopy.rupiah(goal.present))"
                        ),
                        Text("plan.formula.equals \(GoalCopy.rupiah(projection.result))"),
                    ]),
                GoalFormula(
                    title: "plan.kpr.formula.title",
                    lines: [Text("plan.kpr.formula.annuity"), Text("plan.kpr.formula.terms")]),
            ])
    }
}
