import APIClient
import Domain

/** Atur Budget's calls through the authenticated API client: `getCurrentBudget` and `saveCurrentBudget`. */
package struct LiveBudgetSettingsService: BudgetSettingsService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) { self.api = api }

    /** The setup Atur Budget opens with. */
    package func budgetSetup() async throws -> BudgetSetup {
        try await api.budgetSetup()
    }

    /** Simpan Budget. */
    package func saveBudget(_ plan: BudgetPlan) async throws {
        try await api.saveBudget(plan)
    }
}
