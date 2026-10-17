import Domain

extension Operations.GetCurrentBudget.Output {
    func budget() throws -> BudgetOverview {
        switch self {
        case .ok(let response): try budgetOverview(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

/**
 The current budget as Budget reads it. The spec's single goal post carries no name or
 category, so no goal-post row is shown until it does.
 */
func budgetOverview(_ row: Components.Schemas.CurrentBudget) throws -> BudgetOverview {
    guard let start = CalendarDay(iso: row.payday.periodStart),
        let end = CalendarDay(iso: row.payday.periodEnd)
    else { throw AppProblem() }
    let allocations = try row.allocations.map {
        BudgetAllocation(
            category: try bridged($0.category), amount: $0.amount, spent: $0.spent, nearLimit: $0.nearLimit)
    }
    return BudgetOverview(
        income: row.income, remaining: row.remaining,
        period: PayPeriod(start: start, end: end, daysUntilPayday: row.payday.daysUntilPayday),
        allocations: allocations, isConfigured: row.configured)
}
