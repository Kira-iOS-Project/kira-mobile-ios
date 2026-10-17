import APIClient
import Domain
import Foundation
import Observation

/** KIR-39, KIR-117 and KIR-118: the editable allocations, payday and save result. */
@MainActor
@Observable
package final class BudgetEditorModel {
    /** Whether a save is idle, in flight, successful or awaiting a retry. */
    package enum SaveState: Sendable {
        case idle
        case saving
        case saved
        case failed(AppProblem)
    }

    /** The draft shown by the editor. */
    package private(set) var phase: ScreenPhase<BudgetDraft>
    /** Dialog state for the save's result; a failed save leaves the draft intact. */
    package private(set) var saveState: SaveState = .idle
    /** Grouped rupiah strings are kept separately so editing never loses typed digits. */
    package private(set) var amountTexts: [TransactionCategory: String]
    /** Grouped monthly income text. */
    package private(set) var incomeText: String
    /** Count of complete prior periods represented by the displayed averages. */
    package private(set) var averagePeriods = 0
    private var averages: [TransactionCategory: Int] = [:]
    private let service: any BudgetService
    private var pendingDraft: BudgetDraft?

    /** Opens on the current budget, with spending removed from the allocation draft. */
    package init(budget: BudgetOverview?, service: any BudgetService) {
        if let draft = budget?.draft {
            phase = .loaded(draft)
            amountTexts = Dictionary(
                uniqueKeysWithValues: draft.allocations.map { ($0.category, AmountInput.text(for: $0.amount)) })
            incomeText = AmountInput.text(for: draft.income)
        } else {
            phase = .empty
            amountTexts = [:]
            incomeText = ""
        }
        self.service = service
    }

    /** The chosen payday, defaulting to the onboarding preference if the editor has no loaded draft. */
    package var payday: Payday { phase.value?.payday ?? Payday(day: Payday.defaultDay) }

    /** Whether the monthly allocation exceeds income; it remains a valid, savable draft. */
    package var isOverallocated: Bool { phase.value?.isOverallocated ?? false }

    /** The text field contents for one expense category. */
    package func amountText(for category: TransactionCategory) -> String { amountTexts[category] ?? "" }

    /** Updates monthly income from the digits the person typed. */
    package func setIncomeText(_ text: String) {
        guard case .loaded(var draft) = phase else { return }
        incomeText = AmountInput.grouped(text)
        draft.setIncome(AmountInput.value(of: incomeText) ?? 0)
        phase = .loaded(draft)
    }

    /** Average spend from complete prior periods for an expense category, if available. */
    package func averageAmount(for category: TransactionCategory) -> Int? { averages[category] }

    /** Loads server averages independently; an unavailable hint does not block editing. */
    package func loadAverages() async {
        do {
            let context = try await service.currentBudgetEdit()
            averagePeriods = context.averagePeriods
            averages = context.averages.reduce(into: [TransactionCategory: Int]()) { result, average in
                result[average.category] = average.amount
            }
        } catch {
            averagePeriods = 0
            averages = [:]
        }
    }

    /** Updates one category from the digits the person typed. */
    package func setAmountText(_ text: String, for category: TransactionCategory) {
        guard case .loaded(var draft) = phase else { return }
        let grouped = AmountInput.grouped(text)
        amountTexts[category] = grouped
        draft.setAmount(AmountInput.value(of: grouped) ?? 0, for: category)
        phase = .loaded(draft)
    }

    /** Changes the preference; the server resolves its actual payday for the pay period. */
    package func setPayday(_ payday: Payday) {
        guard case .loaded(var draft) = phase else { return }
        draft.payday = payday
        phase = .loaded(draft)
    }

    /** Sends a snapshot of the current draft. An over-allocation is permitted. */
    package func save() async {
        guard let draft = phase.value, !isSaving else { return }
        pendingDraft = draft
        await send(draft)
    }

    /** Repeats the exact draft that failed, even if the visible editor changed meanwhile. */
    package func retry() async {
        guard case .failed = saveState, let draft = pendingDraft else { return }
        await send(draft)
    }

    /** Closes the result dialog; the draft remains available in the editor. */
    package func dismissResult() {
        saveState = .idle
        pendingDraft = nil
    }

    private var isSaving: Bool {
        if case .saving = saveState { return true }
        return false
    }

    private func send(_ draft: BudgetDraft) async {
        saveState = .saving
        do {
            let saved = try await service.saveCurrentBudget(draft)
            phase = .loaded(saved.draft)
            saveState = .saved
        } catch {
            saveState = .failed(error as? AppProblem ?? AppProblem())
        }
    }
}
