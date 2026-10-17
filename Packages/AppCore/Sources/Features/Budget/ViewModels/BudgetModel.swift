import APIClient
import Domain
import Observation

/** Budget (KIR-38): the overview and the server-resolved payday period for the current plan. */
@MainActor
@Observable
package final class BudgetModel {
    /** Loading, the budget, empty while it is not configured, or the problem. */
    package private(set) var phase: ScreenPhase<BudgetOverview> = .loading
    private let service: any BudgetService

    /** Loads the account's current budget through the area's service. */
    package init(service: any BudgetService) {
        self.service = service
    }

    /** Loads the budget, including its server-adjusted pay period; a failure shows its problem (Rule 12). */
    package func load() async {
        do {
            let budget = try await service.currentBudget()
            phase = budget.isConfigured ? .loaded(budget) : .empty
        } catch {
            phase = .failed(AppProblem(error))
        }
    }
}
