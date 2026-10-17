/**
 Tujuan Baru · Lainnya (REN-02h, board TujuanLainnya): Mimpimu (Nama Tujuan, the amount, the years,
 what is set aside), then Strategi Investasimu with Menabung Setiap (Bulan | Tahun) beside Tambah
 Dana di (Awal | Akhir), the deposit and the return. Hitung opens Hasil Simulasi without saving.
 */
import Domain
import Features
import SwiftUI

struct OtherGoalScreen: View {
    @State private var model: OtherGoalModel
    @State private var result: OtherGoalOutcome?
    let onOpen: (AppRoute) -> Void
    /** Jadikan Pos Budget on the result: the caller creates the goal. */
    var onBudget: (OtherGoalOutcome) -> Void = { _ in }

    init(
        model: OtherGoalModel, onOpen: @escaping (AppRoute) -> Void,
        onBudget: @escaping (OtherGoalOutcome) -> Void = { _ in }
    ) {
        _model = State(initialValue: model)
        self.onOpen = onOpen
        self.onBudget = onBudget
    }

    var body: some View {
        GoalFormFrame(
            goal: "plan.other.title", lead: "plan.other.lead", category: .other, canCalculate: model.canCalculate,
            onCalculate: { result = model.outcome }, onHelp: { onOpen(.care) },
            content: {
                KiraSectionTitle("plan.goal.dream").padding(.top, KiraSpacing.space2)
                KiraField("plan.other.name", text: $model.name)
                KiraField("plan.other.amount", text: $model.amount)
                    .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
                KiraField("plan.price.duration", text: $model.duration).suffix("plan.goal.yearsAhead")
                    .keyboardType(.numberPad)
                KiraField("plan.other.present", text: $model.present)
                    .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
                OtherGoalStrategy(model: model)
            }
        )
        .navigationDestination(isPresented: Binding(get: { result != nil }, set: { if !$0 { result = nil } })) {
            if let result { OtherGoalResultScreen(outcome: result, onOpen: onOpen) { onBudget(result) } }
        }
    }
}

/** Strategi Investasimu with Lainnya's two choices before the deposit and the return. */
private struct OtherGoalStrategy: View {
    @Bindable var model: OtherGoalModel

    var body: some View {
        KiraSectionTitle("plan.goal.strategy").padding(.top, KiraSpacing.space2)
        WeightedRow(weights: [1, 1], spacing: 10) {
            choice("plan.other.period") {
                KiraSegmented(
                    "plan.other.period",
                    options: [
                        .init(id: DepositPeriod.month, title: "plan.other.period.month"),
                        .init(id: .year, title: "plan.other.period.year"),
                    ],
                    selection: $model.period)
            }
            choice("plan.other.timing") {
                KiraSegmented(
                    "plan.other.timing",
                    options: [
                        .init(id: DepositTiming.start, title: "plan.other.timing.start"),
                        .init(id: .end, title: "plan.other.timing.end"),
                    ],
                    selection: $model.timing)
            }
        }
        KiraField(model.period == .month ? "plan.goal.deposit" : "plan.other.deposit.year", text: $model.deposit)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
        KiraField("plan.goal.return", text: $model.annualReturn).suffix("plan.goal.perYear")
            .hint("plan.goal.return.hint").keyboardType(.decimalPad)
    }

    /** The board's 13 pt label over a segmented control, which VoiceOver reads from the control itself. */
    private func choice(_ label: LocalizedStringResource, @ViewBuilder control: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1).accessibilityHidden(true)
            control()
        }
    }
}
