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
    /** The API problem from the latest failed save. */
    package private(set) var saveProblem: AppProblem?
    /** Whether the latest save succeeded. */
    package private(set) var hasSaved = false

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
        guard let draft, let update = draft.update, !isSaving else { return }
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

    /** Whether the current draft can be sent. */
    package var canSave: Bool {
        phase.value != nil && draft?.update != nil && !isSaving
    }
}
