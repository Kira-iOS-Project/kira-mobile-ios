import APIClient
import Domain

/** Rencana's calls over the API client. */
package struct LiveGoalService: GoalService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /plan`. */
    package func plan() async throws -> PlanOverview {
        try await api.getPlan()
    }

    /** `GET /goals`. */
    package func goals() async throws -> [GoalSummary] {
        try await api.listGoals()
    }

    /** `GET /goals/{id}`. */
    package func goal(id: String) async throws -> GoalDetail {
        try await api.getGoal(id: id)
    }

    /** `POST /goals`. */
    package func createGoal(_ draft: GoalDraft) async throws -> GoalDetail {
        try await api.createGoal(draft)
    }

    /** `PATCH /goals/{id}`. */
    package func updateGoal(id: String, _ draft: GoalDraft) async throws -> GoalDetail {
        try await api.updateGoal(id: id, draft)
    }

    /** `POST /goals/{id}/deposits`. */
    package func addDeposit(goalId: String, amount: Int, depositedOn: CalendarDay, depositId: String) async throws
        -> GoalDeposit
    {
        try await api.addGoalDeposit(goalId: goalId, amount: amount, depositedOn: depositedOn, depositId: depositId)
    }
}
