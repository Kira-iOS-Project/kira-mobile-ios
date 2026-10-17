import Domain

/** Budget endpoint wrappers used by finance screens. */
extension KiraAPI {
    package func getCurrentBudget() async throws -> BudgetOverview {
        try await client.getCurrentBudget().budget()
    }
}
