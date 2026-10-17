/**
 Tujuan Baru · Dana Pensiun (REN-02e, board TujuanPensiun): Mimpimu (the monthly expenses with
 their yearly sum under them, today's age beside the retirement age, the years left, the yearly
 inflation, the fund already there), then the strategy. Hitung opens Hasil Simulasi without saving
 anything.
 */
import Domain
import Features
import SwiftUI

struct RetirementGoalScreen: View {
    @State private var model: RetirementGoalModel
    @State private var result: RetirementGoalOutcome?
    let onOpen: (AppRoute) -> Void
    /** Jadikan Pos Budget on the result: the caller saves the goal (POST /goals) and goes back to Rencana. */
    var onBudget: (RetirementGoalOutcome) -> Void = { _ in }

    init(
        model: RetirementGoalModel, onOpen: @escaping (AppRoute) -> Void,
        onBudget: @escaping (RetirementGoalOutcome) -> Void = { _ in }
    ) {
        _model = State(initialValue: model)
        self.onOpen = onOpen
        self.onBudget = onBudget
    }

    var body: some View {
        GoalFormFrame(
            goal: "plan.retirement.title", lead: "plan.retirement.lead", category: .retirement,
            canCalculate: model.canCalculate, onCalculate: { result = model.outcome }, onHelp: { onOpen(.care) },
            content: {
                KiraSectionTitle("plan.goal.dream").padding(.top, KiraSpacing.space2)
                RetirementGoalDream(model: model)
                GoalStrategyFields(
                    deposit: $model.deposit, annualReturn: $model.annualReturn,
                    returnHint: "plan.retirement.return.hint")
            }
        )
        .navigationDestination(isPresented: Binding(get: { result != nil }, set: { if !$0 { result = nil } })) {
            if let result {
                RetirementGoalResultScreen(outcome: result, onOpen: onOpen) { onBudget(result) }
            }
        }
    }
}

/** Mimpimu: the fields before the strategy. */
private struct RetirementGoalDream: View {
    @Bindable var model: RetirementGoalModel

    var body: some View {
        expense
        WeightedRow(weights: [1, 1], spacing: 10) {
            KiraField("plan.retirement.age", text: $model.age).suffix("plan.retirement.ageUnit")
                .keyboardType(.numberPad)
            KiraField("plan.retirement.retireAt", text: $model.retirementAge).suffix("plan.retirement.ageUnit")
                .keyboardType(.numberPad)
        }
        if let years = model.years {
            KiraListGroup("plan.price.automatic") {
                KiraListRow(Text("plan.retirement.years"), leading: .icon(.clock), trailing: .none)
                    .subtitle(Text("plan.retirement.years.value \(years)"))
            }
        }
        KiraField("plan.retirement.inflation", text: $model.inflation).suffix("plan.goal.perYear")
            .keyboardType(.decimalPad)
        KiraField("plan.retirement.present", text: $model.present)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
    }

    /** "Pengeluaran per Bulan", with "Setara Rp72.000.000,00 per tahun" once it is typed. */
    @ViewBuilder private var expense: some View {
        let field = KiraField("plan.retirement.expense", text: $model.expense)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount()
        if let annual = model.annualExpense {
            field.hint("plan.retirement.expense.hint \(annual.rupiah.formatted(.rupiah))").keyboardType(.numberPad)
        } else {
            field.keyboardType(.numberPad)
        }
    }
}
