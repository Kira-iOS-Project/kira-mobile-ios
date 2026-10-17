/**
 The form of the goal kind Tujuan Baru chose (`AppRoute.goalForm`), with Jadikan Pos Budget wired to
 `GoalBudgetModel` for the kinds whose result leaves the save to its caller (Pendidikan, Pensiun,
 Kendaraan, Barang, Lainnya): the goal is created,
 a failure shows Coba Lagi and Tutup, and a saved goal goes back to Rencana. DP Rumah and Menikah
 save through their own result screens.
 */
import Domain
import Features
import SwiftUI

struct GoalFormRoute: View {
    /** The kinds with a built form, in TujuanBaru's order; Dana Darurat is not in yet. */
    static let built: [GoalKind] = [.houseDownPayment, .education, .wedding, .retirement, .vehicle, .goods, .other]

    let kind: GoalKind
    let service: any GoalService
    let onOpen: (AppRoute) -> Void
    @State private var budget: GoalBudgetModel
    @State private var draft: GoalDraft?

    init(kind: GoalKind, service: any GoalService, onOpen: @escaping (AppRoute) -> Void) {
        self.kind = kind
        self.service = service
        self.onOpen = onOpen
        _budget = State(initialValue: GoalBudgetModel(service: service))
    }

    var body: some View {
        form
            .goalBudgetDialog(budget, draft: draft ?? placeholder)
            .onChange(of: budget.saved) { _, saved in
                if saved != nil { onOpen(.plan) }
            }
    }

    @ViewBuilder private var form: some View {
        switch kind {
        case .houseDownPayment: HouseDownPaymentFormScreen(service: service, onOpen: onOpen)
        case .wedding: WeddingFormScreen(service: service, onOpen: onOpen)
        case .retirement:
            RetirementGoalScreen(model: RetirementGoalModel(), onOpen: onOpen) { save($0.draft(today: today)) }
        case .vehicle, .goods:
            PriceGoalScreen(
                model: PriceGoalModel(kind: kind, horizon: kind == .vehicle ? .years : .months), onOpen: onOpen
            ) { save($0.draft(kind: kind, today: today)) }
        case .other: OtherGoalScreen(model: OtherGoalModel(), onOpen: onOpen) { save($0.draft(today: today)) }
        case .education: EducationGoalScreen(onOpen: onOpen) { save($0.draft(today: today)) }
        case .emergencyFund: EmptySlot()
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
        self.draft = draft
        Task { await budget.save(draft) }
    }
}
