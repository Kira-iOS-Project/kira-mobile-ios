import APIClient
import Domain

/** Reads the current budget through the authenticated API client. */
package struct LiveBudgetService: BudgetService {
    private let api: KiraAPI

    /** Calls through the generated-client wrapper. */
    package init(api: KiraAPI) { self.api = api }

    /** Loads allocations, spending and the server-resolved pay period. */
    package func currentBudget() async throws -> BudgetOverview {
        try await api.getCurrentBudget()
    }
}
