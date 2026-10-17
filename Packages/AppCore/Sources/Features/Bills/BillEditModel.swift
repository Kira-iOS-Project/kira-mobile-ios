import APIClient
import Domain
import Foundation
import Observation

/** UNG-07c: loads and edits the future schedule for one ordinary recurring bill. */
@MainActor
@Observable
package final class BillEditModel {
    /** The load phase for the selected bill. */
    package private(set) var phase: ScreenPhase<RecurringBill> = .loading
    /** The editable values; failures never replace this draft. */
    package var draft: BillEditDraft?
    /** Whether a save request is in flight. */
    package private(set) var isSaving = false
    /** Whether the person has tried to save the current form. */
    package private(set) var showsFieldErrors = false
    /** The API problem from the latest failed save. */
    package private(set) var saveProblem: AppProblem?
    /** Whether the latest save succeeded. */
    package private(set) var hasSaved = false
    /** Whether the deletion request is in flight. */
    package private(set) var isDeleting = false
    /** The API problem from the latest failed deletion. */
    package private(set) var deleteProblem: AppProblem?
    /** Whether the server has cancelled this schedule. */
    package private(set) var hasDeleted = false

    private let id: String
    private let service: any BillEditService

    /** The screen model for one API bill id. */
    package init(id: String, service: any BillEditService) {
        self.id = id
        self.service = service
    }

    /** Loads the schedule and seeds the form only for a regular bill. */
    package func load() async {
        if phase.value == nil { phase = .loading }
        do {
            let bill = try await service.bill(id: id)
            guard let initial = BillEditDraft(bill: bill) else {
                draft = nil
                phase = .empty
                return
            }
            draft = initial
            phase = .loaded(bill)
        } catch {
            draft = nil
            phase = .failed(billEditProblem(error))
        }
    }

    /** Saves a valid form while preserving the draft after a server refusal. */
    package func save() async {
        showsFieldErrors = true
        guard let draft, let update = draft.update, !isSaving, !isDeleting, !hasDeleted else { return }
        isSaving = true
        saveProblem = nil
        hasSaved = false
        defer { isSaving = false }
        do {
            let updated = try await service.updateBill(id: id, update: update)
            phase = .loaded(updated)
            self.draft = BillEditDraft(bill: updated)
            hasSaved = true
        } catch {
            saveProblem = billEditProblem(error)
        }
    }

    /** Cancels only the future schedule and leaves the loaded form intact if the API refuses. */
    package func delete() async {
        guard canDelete else { return }
        isDeleting = true
        deleteProblem = nil
        defer { isDeleting = false }
        do {
            try await service.deleteBill(id: id)
            hasDeleted = true
        } catch {
            deleteProblem = billEditProblem(error)
        }
    }

    /** Whether the current draft can be sent. */
    package var canSave: Bool {
        phase.value != nil && draft?.update != nil && !isSaving && !isDeleting && !hasDeleted
    }

    /** Whether the loaded schedule can be cancelled now. */
    package var canDelete: Bool { phase.value != nil && !isSaving && !isDeleting && !hasDeleted }

    /** Expense categories offered by the recurring-bill form. */
    package var categories: [TransactionCategory] {
        TransactionCategory.allCases.filter { $0.type == .expense }
    }

    /** A required-name or length message after a save attempt. */
    package var nameError: LocalizedStringResource? {
        guard showsFieldErrors, let draft else { return nil }
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty { return "bills.edit.name.required" }
        return name.count > 80 ? "bills.edit.name.tooLong" : nil
    }

    /** A positive-rupiah message after a save attempt. */
    package var amountError: LocalizedStringResource? {
        guard showsFieldErrors, let draft else { return nil }
        return AmountInput.amount(draft.amountText) == nil ? "bills.edit.amount.required" : nil
    }
}
