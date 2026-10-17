import APIClient
import Domain
import Observation

/**
 Rencana (REN-01), the Rencana tab's root: the four-step ladder from the engine, the goals, and the
 doors to the risk quiz, Cek Legalitas and Portofolio Manual. It loads each time the tab shows, and
 keeps what it has on screen while it loads again, so coming back from a goal never flashes.
 */
@MainActor
@Observable
package final class PlanModel {
    /** The plan, loading until the API answers. */
    package private(set) var phase: ScreenPhase<PlanOverview> = .loading

    @ObservationIgnored private let service: any GoalService

    /** A model that loads through `service`. */
    package init(service: any GoalService) {
        self.service = service
    }

    /** Loads the plan, or loads it again; what is on screen stays until the answer comes. */
    package func load() async {
        if phase.value == nil { phase = .loading }
        do {
            phase = .loaded(try await service.plan())
        } catch {
            /** Leaving the tab cancels the load: it stays as it was for the next appearance. */
            guard !Task.isCancelled else { return }
            if phase.value == nil { phase = .failed(AppProblem(error)) }
        }
    }

    /** The emergency-fund goal, which ladder step 2 shows the progress of; nil before it is set. */
    package var emergencyGoal: GoalSummary? {
        phase.value?.goals.first { $0.kind == .emergencyFund }
    }

    /** The emergency fund's target in months of essential spending, from ladder step 2 ("Target 6×"). */
    package var emergencyTargetMultiple: Double? {
        phase.value?.ladder.first { $0.key == .emergencyFund }?.detail.targetMultiple.map(Double.init)
    }
}
