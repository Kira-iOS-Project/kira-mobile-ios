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

func budgetOverview(_ row: Components.Schemas.CurrentBudget) throws -> BudgetOverview {
    let payday: Payday
    switch row.payday.requested {
    case .case1(let day): payday = Payday(day: day.day)
    case .case2: payday = .endOfMonth
    }
    guard let start = CalendarDay(iso: row.payday.periodStart),
        let end = CalendarDay(iso: row.payday.periodEnd)
    else { throw AppProblem() }
    let allocations = try row.allocations.map {
        BudgetAllocation(
            category: try bridged($0.category), amount: $0.amount, spent: $0.spent, nearLimit: $0.nearLimit)
    }
    let goals = row.goalPosts.map { goal in
        BudgetGoalPost(
            category: goal.category.rawValue, name: goal.name, currentAmount: goal.currentAmount,
            targetAmount: goal.targetAmount,
            milestones: goal.milestones.map {
                BudgetGoalMilestone(amount: $0.amount, label: $0.label, reached: $0.reached)
            })
    }
    return BudgetOverview(
        income: row.income, remaining: row.remaining, goalPosts: goals, payday: payday,
        period: PayPeriod(start: start, end: end, daysUntilPayday: row.payday.daysUntilPayday),
        allocations: allocations, isConfigured: row.configured)
}
