import Domain

/** The budget API boundary used by the overview and editor screens. */
package protocol BudgetService: Sendable {
    /** The current budget and profile defaults, including whether allocations have been configured. */
    func currentBudget() async throws -> BudgetOverview

    /** The current budget and averages from up to three complete earlier pay periods. */
    func currentBudgetEdit() async throws -> BudgetEditContext

    /** Persists income, category allocations, and the requested payday. */
    func saveCurrentBudget(_ draft: BudgetDraft) async throws -> BudgetOverview
}

extension BudgetService {
    /** Older and preview services can omit average hints when they have no history. */
    package func currentBudgetEdit() async throws -> BudgetEditContext {
        BudgetEditContext(budget: try await currentBudget(), averagePeriods: 0, averages: [])
    }
}
