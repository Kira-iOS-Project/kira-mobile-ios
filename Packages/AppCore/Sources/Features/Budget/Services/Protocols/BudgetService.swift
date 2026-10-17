import Domain

/** The budget API boundary used by the overview screen. */
package protocol BudgetService: Sendable {
    /** The current budget and profile defaults, including whether allocations have been configured. */
    func currentBudget() async throws -> BudgetOverview
}
