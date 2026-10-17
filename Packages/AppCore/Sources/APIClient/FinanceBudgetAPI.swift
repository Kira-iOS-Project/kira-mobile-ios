import Domain

/** Budget endpoint wrappers used by finance screens. */
extension KiraAPI {
    /** `GET /api/budgets/current`: this pay period's budget, or one not configured yet. */
    package func getCurrentBudget() async throws -> BudgetOverview {
        try await client.getCurrentBudget().budget()
    }
}
