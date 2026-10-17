import Domain

/**
 Rencana's calls (CONTRACT-REN): the plan with its ladder and goals, each goal in full, creating and
 changing a goal the device computed, and putting money into one. Every call throws an `AppProblem`
 when the API refuses it: 404 `GOAL_NOT_FOUND`, 409 `GOAL_EMERGENCY_EXISTS`, 422 out of range.
 */
package protocol GoalService: Sendable {
    /** `GET /plan` (`getPlan`). */
    func plan() async throws -> PlanOverview
    /** `GET /goals` (`listGoals`). */
    func goals() async throws -> [GoalSummary]
    /** `GET /goals/{id}` (`getGoal`): one goal with its deposits and milestones. */
    func goal(id: String) async throws -> GoalDetail
    /** `POST /goals` (`createGoal`): Jadikan Pos Budget. */
    func createGoal(_ draft: GoalDraft) async throws -> GoalDetail
    /** `PATCH /goals/{id}` (`updateGoal`). */
    func updateGoal(id: String, _ draft: GoalDraft) async throws -> GoalDetail
    /**
     `POST /goals/{id}/deposits` (`addGoalDeposit`): `depositId` makes a retry after a lost answer
     land once (an id used on another goal: 409 `GOAL_DEPOSIT_CONFLICT`). Returns the deposit stored.
     */
    func addDeposit(goalId: String, amount: Int, depositedOn: CalendarDay, depositId: String) async throws
        -> GoalDeposit
}
