/**
 Tujuan Baru · Kendaraan (REN-02f, board TujuanKendaraan) and · Barang Impian (REN-02g, board
 TujuanBarang): Mimpimu (Barang names the thing; the horizon in years or months; today's price;
 the DP share beside the price inflation; Kendaraan's automatic DP and KKB principal; what is set
 aside), then the strategy. Hitung opens Hasil Simulasi without saving anything.
 */
import Domain
import Features
import SwiftUI

struct PriceGoalScreen: View {
    @State private var model: PriceGoalModel
    @State private var result: PriceGoalOutcome?
    let onOpen: (AppRoute) -> Void

    init(model: PriceGoalModel, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: model)
        self.onOpen = onOpen
    }

    var body: some View {
        let copy = PriceGoalCopy(kind: model.kind)
        GoalFormFrame(
            goal: copy.title, lead: copy.lead, category: copy.category, canCalculate: model.canCalculate,
            onCalculate: { result = model.outcome }, onHelp: { onOpen(.care) },
            content: {
            KiraSectionTitle("plan.goal.dream").padding(.top, KiraSpacing.space2)
            PriceGoalDream(model: model, copy: copy)
            GoalStrategyFields(deposit: $model.deposit, annualReturn: $model.annualReturn)
            })
        .navigationDestination(isPresented: Binding(get: { result != nil }, set: { if !$0 { result = nil } })) {
            if let result { PriceGoalResultScreen(outcome: result, kind: model.kind, onOpen: onOpen) }
        }
    }
}

/** Mimpimu: the fields before the strategy. */
private struct PriceGoalDream: View {
    @Bindable var model: PriceGoalModel
    let copy: PriceGoalCopy

    var body: some View {
        if model.kind == .goods {
            KiraField("plan.goods.name", text: $model.name)
        }
        KiraField("plan.price.duration", text: $model.duration).suffix(copy.durationUnit).keyboardType(.numberPad)
        KiraField(copy.priceLabel, text: $model.price)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
        WeightedRow(weights: [1, 1], spacing: 10) {
            KiraField("plan.price.downPayment", text: $model.downPayment).suffix("plan.price.percent")
                .hint(copy.downPaymentHint).keyboardType(.decimalPad)
            KiraField("plan.price.inflation", text: $model.inflation).suffix("plan.goal.perYear")
                .keyboardType(.decimalPad)
        }
        if model.kind == .vehicle {
            KiraListGroup("plan.price.automatic") {
                KiraListRow(Text("plan.vehicle.downPaymentAmount"), leading: .icon(.wallet), trailing: .none)
                    .amount(KiraAmount((model.downPaymentAmount ?? 0).rupiah))
                if let loan = model.loanPrincipal, let share = GoalInput.percent(model.downPayment) {
                    KiraListRow(
                        Text("plan.vehicle.loan \(Text((1 - share) * 100, format: .kiraMultiple))"),
                        leading: .icon(.receipt), trailing: .none
                    )
                    .subtitle(Text("plan.vehicle.loan.subtitle")).amount(KiraAmount(loan.rupiah))
                }
            }
        }
        KiraField(copy.presentLabel, text: $model.present)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
    }
}

/** The words that differ between Kendaraan and Barang Impian. */
struct PriceGoalCopy {
    let kind: GoalKind

    var title: LocalizedStringResource { kind == .vehicle ? "plan.vehicle.title" : "plan.goods.title" }
    var lead: LocalizedStringResource { kind == .vehicle ? "plan.vehicle.lead" : "plan.goods.lead" }
    var category: KiraCategory { kind == .vehicle ? .transport : .goods }
    var durationUnit: LocalizedStringResource { kind == .vehicle ? "plan.goal.yearsAhead" : "plan.price.monthsAhead" }
    var priceLabel: LocalizedStringResource { kind == .vehicle ? "plan.vehicle.price" : "plan.goods.price" }
    var downPaymentHint: LocalizedStringResource {
        kind == .vehicle ? "plan.vehicle.downPayment.hint" : "plan.goods.downPayment.hint"
    }
    var presentLabel: LocalizedStringResource { kind == .vehicle ? "plan.vehicle.present" : "plan.goods.present" }
}
