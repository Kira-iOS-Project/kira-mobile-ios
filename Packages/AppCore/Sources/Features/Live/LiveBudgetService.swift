import APIClient
import Domain

/** Reads and writes budget data through the authenticated API client. */
package struct LiveBudgetService: BudgetService {
    private let api: KiraAPI

    /** Calls through the generated-client wrapper. */
    package init(api: KiraAPI) { self.api = api }

    /** Loads allocations, spending and the server-resolved pay period. */
    package func currentBudget() async throws -> BudgetOverview {
        try await api.getCurrentBudget()
    }

    /** Loads average spending from complete earlier pay periods. */
    package func currentBudgetEdit() async throws -> BudgetEditContext {
        try await api.getCurrentBudgetEdit()
    }

    /** Saves the person's changes and returns the server-resolved payday period. */
    package func saveCurrentBudget(_ draft: BudgetDraft) async throws -> BudgetOverview {
        try await api.updateCurrentBudget(draft)
    }
}
