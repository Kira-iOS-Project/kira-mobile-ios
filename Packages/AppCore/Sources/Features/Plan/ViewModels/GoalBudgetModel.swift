import APIClient
import Domain
import Observation

/**
 Jadikan Pos Budget, under every Hasil Simulasi: creates the goal as the device computed it
 (`POST /goals`), or, from Ubah Tujuan, saves the goal's new figures (`PATCH /goals/{id}`). It goes
 once at a time; a failure keeps the result on screen and shows the failure dialog (Coba Lagi,
 Tutup); a goal saved goes back to where it came from.
 */
@MainActor
@Observable
package final class GoalBudgetModel {
    /** Whether the create is on its way. */
    package private(set) var isSaving = false
    /** The failure dialog's problem; nil when none shows. */
    package var failure: AppProblem?
    /** The draft last sent, which the failure dialog's Coba Lagi sends again. */
    package private(set) var draft: GoalDraft?
    /** The goal once created: the screen goes back to Rencana. */
    package private(set) var saved: GoalDetail?

    /** The goal Ubah Tujuan changes; nil when a new goal is made. */
    package let goalId: String?
    private let service: any GoalService

    /** Creates goals through `service`, or changes the goal `goalId` names. */
    package init(service: any GoalService, goalId: String? = nil) {
        self.service = service
        self.goalId = goalId
    }

    /** Creates or changes `draft`'s goal; Coba Lagi calls it again with the same draft. */
    package func save(_ draft: GoalDraft) async {
        guard !isSaving else { return }
        self.draft = draft
        isSaving = true
        defer { isSaving = false }
        failure = nil
        do {
            if let goalId {
                saved = try await service.updateGoal(id: goalId, draft)
            } else {
                saved = try await service.createGoal(draft)
            }
        } catch {
            failure = AppProblem(error)
        }
    }
}
