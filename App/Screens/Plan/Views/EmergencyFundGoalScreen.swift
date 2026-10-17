/**
 Kalkulator Dana Darurat (REN-03, board KalkulatorDarurat): Kebutuhanmu (Pengeluaran Pokok per Bulan
 from the records, Sudah Menikah? beside Jumlah Tanggungan, and the fund that makes), Mimpimu (the
 months and what is there), then Strategi Investasimu. Hitung opens Hasil Simulasi (REN-04).
 */
import Domain
import Features
import SwiftUI

struct EmergencyFundGoalScreen: View {
    @State private var model: EmergencyFundGoalModel
    @State private var result: EmergencyFundOutcome?
    let onOpen: (AppRoute) -> Void
    /** Rencana's prefill (`GET /plan`); nil when it cannot be read, and the form stays as it is. */
    var prefill: () async -> PlanPrefill? = { nil }
    /** Jadikan Pos Budget on the result: the caller creates the goal. */
    var onBudget: (EmergencyFundOutcome) -> Void = { _ in }

    init(
        model: EmergencyFundGoalModel, onOpen: @escaping (AppRoute) -> Void,
        prefill: @escaping () async -> PlanPrefill? = { nil },
        onBudget: @escaping (EmergencyFundOutcome) -> Void = { _ in }
    ) {
        _model = State(initialValue: model)
        self.onOpen = onOpen
        self.prefill = prefill
        self.onBudget = onBudget
    }

    var body: some View {
        GoalFormFrame(
            goal: "plan.emergency.form.title", lead: "plan.emergency.form.lead", category: .emergency,
            canCalculate: model.canCalculate, onCalculate: { result = model.outcome }, onHelp: { onOpen(.care) },
            content: { EmergencyFundFields(model: model) }
        )
        .task { if let known = await prefill() { model.apply(known) } }
        .navigationDestination(isPresented: Binding(get: { result != nil }, set: { if !$0 { result = nil } })) {
            if let result { EmergencyFundResultScreen(outcome: result, onOpen: onOpen) { onBudget(result) } }
        }
    }
}

/** The board's fields, in its order. */
private struct EmergencyFundFields: View {
    @Bindable var model: EmergencyFundGoalModel

    var body: some View {
        KiraSectionTitle("plan.emergency.form.needs").padding(.top, KiraSpacing.space2)
        KiraField("plan.emergency.form.essential", text: $model.essential)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").hint("plan.emergency.form.essential.hint").amount()
            .keyboardType(.numberPad)
        WeightedRow(weights: [1, 1], spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text("plan.emergency.form.married").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                    .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1).accessibilityHidden(true)
                KiraSegmented(
                    "plan.emergency.form.married",
                    options: [
                        .init(id: false, title: "plan.emergency.form.married.no"),
                        .init(id: true, title: "plan.emergency.form.married.yes"),
                    ],
                    selection: $model.married)
            }
            KiraField("plan.emergency.form.dependants", text: $model.dependants)
                .suffix("plan.emergency.form.people").keyboardType(.numberPad)
        }
        if let needed = model.neededFund {
            KiraListGroup("plan.emergency.form.automatic") {
                KiraListRow(Text("plan.emergency.form.needed"), leading: .icon(.shield), trailing: .none)
                    .subtitle(Text("plan.emergency.form.needed.multiple \(needed.multiplier)"))
                    .amount(KiraAmount(needed.target.rupiah))
            }
        }
        KiraSectionTitle("plan.goal.dream").padding(.top, KiraSpacing.space2)
        KiraField("plan.price.duration", text: $model.months).suffix("plan.emergency.form.monthsAhead")
            .keyboardType(.numberPad)
        KiraField("plan.emergency.form.present", text: $model.present)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").hint("plan.emergency.form.present.hint").amount()
            .keyboardType(.numberPad)
        KiraSectionTitle("plan.goal.strategy").padding(.top, KiraSpacing.space2)
        KiraField("plan.goal.deposit", text: $model.deposit)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
        KiraField("plan.goal.return", text: $model.annualReturn).suffix("plan.goal.perYear")
            .hint("plan.emergency.form.return.hint").keyboardType(.decimalPad)
    }
}
