/**
 Tujuan Baru · Pendidikan Anak (REN-02c, board TujuanPendidikan): Tentang Anakmu, Rencana Pendidikan
 (Jenjang Awal and Akhir, then each stage's costs, a tap opening Atur Jenjang), Kondisi Keuanganmu,
 then the strategy with Sudah Tahu Mau Investasi di Mana?. Hitung opens Hasil Simulasi without saving.
 */
import Domain
import Features
import SwiftUI

struct EducationGoalScreen: View {
    @State private var model: EducationGoalModel
    @State private var result: EducationGoalOutcome?
    @State private var editing: EducationStage?
    let onOpen: (AppRoute) -> Void
    /** Jadikan Pos Budget on the result: the caller creates the goal. */
    var onBudget: (EducationGoalOutcome) -> Void = { _ in }

    init(
        model: EducationGoalModel = EducationGoalModel(), onOpen: @escaping (AppRoute) -> Void,
        onBudget: @escaping (EducationGoalOutcome) -> Void = { _ in }
    ) {
        _model = State(initialValue: model)
        self.onOpen = onOpen
        self.onBudget = onBudget
    }

    var body: some View {
        GoalFormFrame(
            goal: "plan.education.title", lead: "plan.education.lead", category: .education,
            canCalculate: model.canCalculate, onCalculate: { result = model.outcome }, onHelp: { onOpen(.care) },
            content: {
                EducationChildFields(model: model)
                EducationStageFields(model: model, onEdit: { editing = $0 })
                EducationMoneyFields(model: model)
                EducationStrategyFields(model: model)
            }
        )
        .navigationDestination(isPresented: showsResult) {
            if let result { EducationGoalResultScreen(outcome: result, onOpen: onOpen) { onBudget(result) } }
        }
        .navigationDestination(isPresented: showsStage) {
            if let editing {
                EducationStageScreen(stage: editing, values: model.values(for: editing)) {
                    model.save($0, for: editing)
                }
            }
        }
    }

    private var showsResult: Binding<Bool> {
        Binding(get: { result != nil }, set: { if !$0 { result = nil } })
    }

    private var showsStage: Binding<Bool> {
        Binding(get: { editing != nil }, set: { if !$0 { editing = nil } })
    }
}
