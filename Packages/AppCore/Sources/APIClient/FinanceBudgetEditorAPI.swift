import Domain

/** Budget edit and save endpoint wrappers. */
extension KiraAPI {
    package func getCurrentBudgetEdit() async throws -> BudgetEditContext {
        try await client.getCurrentBudgetEdit(.init()).budgetEdit()
    }

    package func updateCurrentBudget(_ draft: BudgetDraft) async throws -> BudgetOverview {
        let payday: Components.Schemas.UpdateCurrentBudgetInput.PaydayPayload
        if let day = draft.payday.day {
            payday = .case1(.init(_type: .day, day: day))
        } else {
            payday = .case2(.init(_type: .endOfMonth))
        }
        let body = Components.Schemas.UpdateCurrentBudgetInput(
            income: draft.income,
            allocations: try draft.allocations.map {
                .init(category: try bridged($0.category), amount: $0.amount)
            },
            payday: payday)
        return try await client.updateCurrentBudget(body: .json(body)).budget()
    }
}
