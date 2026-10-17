import APIClient
import Domain
import Observation

/** Budget (KIR-38): the overview and the server-resolved payday period for the current plan. */
@MainActor
@Observable
package final class BudgetModel {
    /** Current budget, loading until the API answers. */
    package private(set) var phase: ScreenPhase<BudgetOverview> = .loading
    private let service: any BudgetService

    /** Loads the account's current budget through the area's service. */
    package init(service: any BudgetService) {
        self.service = service
    }

    /** Loads the budget, including its server-adjusted pay period. */
    package func load() async {
        do {
            phase = .loaded(try await service.currentBudget())
        } catch {
            phase = .failed(error as? AppProblem ?? AppProblem())
        }
    }
}
