/**
 Rencana until the API client carries its operations (`getPlan`, `getGoal`, `addGoalDeposit`, …):
 every call fails, so the screens say so rather than show sample figures as the person's own. The
 live service replaces it once the client is regenerated from the REN spec.
 */
import APIClient
import Domain
import Features

struct PendingGoalService: GoalService {
    func plan() throws -> PlanOverview { throw AppProblem() }
    func goals() throws -> [GoalSummary] { throw AppProblem() }
    func goal(id _: String) throws -> GoalDetail { throw AppProblem() }
    func createGoal(_: GoalDraft) throws -> GoalDetail { throw AppProblem() }
    func updateGoal(id _: String, _: GoalDraft) throws -> GoalDetail { throw AppProblem() }
    func addDeposit(goalId _: String, amount _: Int, depositedOn _: CalendarDay, depositId _: String) throws
        -> GoalDeposit
    {
        throw AppProblem()
    }
}
