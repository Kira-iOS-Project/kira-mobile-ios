/**
 A plan that cannot be read (`GET /plan` fails with a lost connection): the quiz then shows no
 ladder notice and the board's ranges without the income, for `-KiraScreen riskQuizUnreadablePlan`.
 */
import APIClient
import Domain
import Features

struct UnreadablePlanService: GoalService {
    func plan() throws -> PlanOverview { throw AppProblem.connectionLost }

    func goal(id _: String) throws -> GoalDetail { throw AppProblem.connectionLost }

    func createGoal(_: GoalDraft) throws -> GoalDetail { throw AppProblem.connectionLost }

    func updateGoal(id _: String, _: GoalDraft) throws -> GoalDetail { throw AppProblem.connectionLost }

    func addDeposit(goalId _: String, amount _: Int, depositedOn _: CalendarDay, depositId _: String) throws
        -> GoalDeposit
    { throw AppProblem.connectionLost }
}
