import Domain
import Foundation

/**
 Rencana's plan and goals (tag Rencana): the ladder with the goals, one goal in full, a new goal, a
 goal changed or deleted, and a deposit, idempotent by its id.
 */
extension KiraAPI {
    /** The ladder, the goals, the risk profile and the prefill (`GET /api/plan`). */
    package func getPlan() async throws -> PlanOverview {
        try await client.getPlan().plan()
    }

    /** One goal with its deposits and milestones; 404 `GOAL_NOT_FOUND` (`GET /api/goals/{id}`). */
    package func getGoal(id: String) async throws -> GoalDetail {
        try await client.getGoal(path: .init(id: id)).goal()
    }

    /** A new goal; 409 `GOAL_EMERGENCY_EXISTS` for a second emergency fund (`POST /api/goals`). */
    package func createGoal(_ draft: GoalDraft) async throws -> GoalDetail {
        try await client.createGoal(body: .json(.init(draft))).goal()
    }

    /** A goal changed to `draft`'s figures (Ubah Tujuan); 404 `GOAL_NOT_FOUND` (`PATCH /api/goals/{id}`). */
    package func updateGoal(id: String, _ draft: GoalDraft) async throws -> GoalDetail {
        try await client.updateGoal(path: .init(id: id), body: .json(.init(draft))).goal()
    }

    /** Hapus Tujuan: the goal and its deposits go; 404 `GOAL_NOT_FOUND` (`DELETE /api/goals/{id}`). */
    package func deleteGoal(id: String) async throws {
        try await client.deleteGoal(path: .init(id: id)).deleted()
    }

    /** A deposit; the same id lands once, an id another goal used is 409 `GOAL_DEPOSIT_CONFLICT`. */
    package func addGoalDeposit(goalId: String, amount: Int, depositedOn: CalendarDay, depositId: String)
        async throws -> GoalDeposit
    {
        let body = Components.Schemas.GoalDepositInput(
            depositId: depositId, amount: amount, depositedOn: depositedOn.iso)
        return try await client.addGoalDeposit(path: .init(id: goalId), body: .json(body)).deposit()
    }
}
