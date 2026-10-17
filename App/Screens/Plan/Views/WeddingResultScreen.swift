/**
 REN-04e, Hasil Simulasi · Menikah (board HasilTujuanMenikah): the shared result for the budget in
 the wedding's year, with Supaya Tercapai while it falls short. Jadikan Pos Budget creates the goal
 and goes back to Rencana; a failure keeps the result and shows Coba Lagi and Tutup.
 */
import Domain
import Features
import SwiftUI

struct WeddingResultScreen: View {
    let goal: WeddingGoal
    let preset: WeddingPreset?
    private let onOpen: (AppRoute) -> Void
    @State private var budget: GoalBudgetModel
    @Environment(\.dismiss) private var dismiss

    init(goal: WeddingGoal, preset: WeddingPreset?, service: any GoalService, onOpen: @escaping (AppRoute) -> Void) {
        self.goal = goal
        self.preset = preset
        self.onOpen = onOpen
        _budget = State(initialValue: GoalBudgetModel(service: service))
    }

    var body: some View {
        let draft = goal.draft(today: CalendarDay(.now), preset: preset)
        GoalResultFrame(
            content: content, isSaving: budget.isSaving, onEdit: { _ in dismiss() },
            onBudget: { Task { await budget.save(draft) } }, onHelp: { onOpen(.care) })
            .goalBudgetDialog(budget, draft: draft)
            .onChange(of: budget.saved) { _, saved in
                if saved != nil { onOpen(.plan) }
            }
    }

    private var content: GoalResultContent {
        let projection = goal.projection
        let inflation = GoalCopy.percent(goal.inflation)
        let caption: Text =
            if let preset {
                Text("plan.wedding.caption \(Text(preset.title)) \(goal.years) \(inflation)")
            } else {
                Text("plan.wedding.caption.own \(goal.years) \(inflation)")
            }
        return GoalResultContent(
            goal: "plan.wedding.goal", overline: "plan.result.overline.total", caption: caption,
            projection: projection, present: goal.present, deposit: goal.deposit, annualReturn: goal.annualReturn,
            horizon: .years(goal.years), recommendations: goal.recommendations,
            assetClasses: GoalMath.assetClasses(years: Double(goal.years)),
            formulas: [
                GoalFormula(
                    title: "plan.formula.target",
                    lines: [
                        GoalCopy.rupiah(goal.cost),
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
            ])
    }
}
