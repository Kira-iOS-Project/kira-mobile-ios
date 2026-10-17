/**
 Rencana on the canvas's sample whose writes never get an answer (a lost connection): for the
 failure dialog of Jadikan Pos Budget in previews and `-KiraScreen`.
 */
import APIClient
import Domain
import Features

struct UnansweredGoalService: GoalService {
    private let preview = PreviewGoalService()

    func plan() async -> PlanOverview { await preview.plan() }

    func goal(id: String) async -> GoalDetail { await preview.goal(id: id) }

    func createGoal(_: GoalDraft) throws -> GoalDetail { throw AppProblem.connectionLost }

    func addDeposit(goalId _: String, amount _: Int, depositedOn _: CalendarDay, depositId _: String) throws
        -> GoalDeposit
    {
        throw AppProblem.connectionLost
    }
}
