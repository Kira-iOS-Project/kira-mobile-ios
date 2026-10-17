import APIClient
import Domain
import Observation

/**
 Jadikan Pos Budget, under every Hasil Simulasi: creates the goal as the device computed it
 (`POST /goals`). It goes once at a time; a failure keeps the result on screen and shows the
 failure dialog (Coba Lagi, Tutup); a goal saved goes back to Rencana.
 */
@MainActor
@Observable
package final class GoalBudgetModel {
    /** Whether the create is on its way. */
    package private(set) var isSaving = false
    /** The failure dialog's problem; nil when none shows. */
    package var failure: AppProblem?
    /** The goal once created: the screen goes back to Rencana. */
    package private(set) var saved: GoalDetail?

    private let service: any GoalService

    /** Creates goals through `service`. */
    package init(service: any GoalService) {
        self.service = service
    }

    /** Creates `draft`'s goal; Coba Lagi calls it again with the same draft. */
    package func save(_ draft: GoalDraft) async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        failure = nil
        do {
            saved = try await service.createGoal(draft)
        } catch {
            failure = AppProblem(error)
        }
    }
}
