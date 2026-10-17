import APIClient
import Domain
import Observation

/**
 Where Beranda and the score lead for paying off (`AppRoute.debtPlan`): Rencanaku when the person
 has a plan (`loaded`), Rencana Pelunasan when there is none yet (`empty`, 404
 `PAYOFF_PLAN_NOT_FOUND`), or the problem when it could not be asked.
 */
@MainActor @Observable
package final class PayoffEntryModel {
    /** Loading, the plan, no plan yet, or the problem. */
    package private(set) var phase = ScreenPhase<ActivePayoffPlan>.loading
    private let plans: any PayoffPlanService

    /** An entry asking `plans` for the person's plan. */
    package init(plans: any PayoffPlanService) {
        self.plans = plans
    }

    /** Asks for the plan, or again after a failure. */
    package func load() async {
        phase = .loading
        do {
            phase = .loaded(try await plans.active())
        } catch is CancellationError {
            return
        } catch {
            let problem = AppProblem(error)
            phase = problem.knownCode == .payoffPlanNotFound ? .empty : .failed(problem)
        }
    }
}
