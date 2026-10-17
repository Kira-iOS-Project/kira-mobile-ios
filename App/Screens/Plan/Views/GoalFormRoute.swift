/**
 The form of the goal kind Tujuan Baru chose (`AppRoute.goalForm`), with Jadikan Pos Budget wired to
 `GoalBudgetModel` for the kinds whose result leaves the save to its caller (Pendidikan, Pensiun,
 Kendaraan, Barang, Lainnya): the goal is created,
 a failure shows Coba Lagi and Tutup, and a saved goal goes back to Rencana. DP Rumah and Menikah
 save through their own result screens.

 From Ubah Tujuan (`init(editing:)`) the same form opens on the goal's saved figures, its result's
 button reads "Simpan Perubahan" and changes the goal (DP Rumah and Menikah through this route's
 model too), and a saved change goes back to Detail Tujuan.
 */
import Domain
import Features
import SwiftUI

struct GoalFormRoute: View {
    /** The kinds with a built form, in TujuanBaru's order. */
    static let built: [GoalKind] = [
        .emergencyFund, .houseDownPayment, .education, .wedding, .retirement, .vehicle, .goods, .other,
    ]

    let kind: GoalKind
    let service: any GoalService
    let onOpen: (AppRoute) -> Void
    /** The goal Ubah Tujuan changes; nil for a new goal. */
    private let editing: GoalDetail?
    @State private var budget: GoalBudgetModel
    @Environment(\.dismiss) private var dismiss

    init(kind: GoalKind, service: any GoalService, onOpen: @escaping (AppRoute) -> Void) {
        self.kind = kind
        self.service = service
        self.onOpen = onOpen
        editing = nil
        _budget = State(initialValue: GoalBudgetModel(service: service))
    }

    /** Ubah Tujuan: `goal`'s form on its saved figures. */
    init(editing goal: GoalDetail, service: any GoalService, onOpen: @escaping (AppRoute) -> Void) {
        kind = goal.summary.kind
        self.service = service
        self.onOpen = onOpen
        editing = goal
        _budget = State(initialValue: GoalBudgetModel(service: service, goalId: goal.id))
    }

    var body: some View {
        form
            .environment(\.goalSaveLabel, editing == nil ? "plan.result.budget" : "plan.result.saveChanges")
            .environment(\.goalEditBudget, editing == nil ? nil : budget)
            .goalBudgetDialog(budget, draft: budget.draft ?? placeholder)
            .onChange(of: budget.saved) { _, saved in
                guard saved != nil else { return }
                if editing == nil { onOpen(.plan) } else { dismiss() }
            }
    }

    @ViewBuilder private var form: some View {
        switch kind {
        case .houseDownPayment:
            HouseDownPaymentFormScreen(
                service: service,
                model: editing.map { HouseDownPaymentFormModel.editing($0) } ?? HouseDownPaymentFormModel(),
                onOpen: onOpen)
        case .wedding:
            WeddingFormScreen(
                service: service, model: editing.map { WeddingFormModel.editing($0) } ?? WeddingFormModel(),
                onOpen: onOpen)
        case .retirement:
            RetirementGoalScreen(
                model: RetirementGoalModel(
                    values: editing.map { RetirementGoalValues(editing: $0) } ?? RetirementGoalValues()),
                onOpen: onOpen
            ) { save($0.draft(today: today)) }
        case .vehicle, .goods:
            let horizon: PriceGoalModel.Horizon = kind == .vehicle ? .years : .months
            PriceGoalScreen(
                model: PriceGoalModel(
                    kind: kind, horizon: horizon,
                    values: editing.map { PriceGoalValues(editing: $0, horizon: horizon) } ?? PriceGoalValues()),
                onOpen: onOpen
            ) { save($0.draft(kind: kind, today: today)) }
        case .other:
            OtherGoalScreen(
                model: OtherGoalModel(values: editing.map { OtherGoalValues(editing: $0) } ?? OtherGoalValues()),
                onOpen: onOpen
            ) { save($0.draft(today: today)) }
        case .education:
            EducationGoalScreen(
                model: editing.map { EducationGoalModel.editing($0) } ?? EducationGoalModel(), onOpen: onOpen
            ) {
                save($0.draft(today: today))
            }
        case .emergencyFund:
            if let editing {
                EmergencyFundGoalScreen(
                    model: .editing(editing), onOpen: onOpen, onBudget: { save($0.draft(today: today)) })
            } else {
                EmergencyFundGoalScreen(
                    model: EmergencyFundGoalModel(), onOpen: onOpen,
                    prefill: { [service] in try? await service.plan().prefill },
                    onBudget: { save($0.draft(today: today)) })
            }
        }
    }

    private var today: CalendarDay { CalendarDay(.now) }

    /** The dialog shows only after a save, so its Coba Lagi always has the real draft. */
    private var placeholder: GoalDraft {
        GoalDraft(
            kind: kind, name: "", inputs: [:], initialAmount: 0, monthlyDeposit: 0, targetAmount: 0,
            targetDate: today, inBudget: true)
    }

    private func save(_ draft: GoalDraft) {
        Task { await budget.save(draft) }
    }
}
