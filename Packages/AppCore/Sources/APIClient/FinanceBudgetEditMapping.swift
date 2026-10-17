import Domain

extension Operations.UpdateCurrentBudget.Output {
    func budget() throws -> BudgetOverview {
        switch self {
        case .ok(let response): try budgetOverview(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}

extension Operations.GetCurrentBudgetEdit.Output {
    func budgetEdit() throws -> BudgetEditContext {
        switch self {
        case .ok(let response):
            let edit = try response.body.json
            let averages = try edit.value2.averages.map {
                BudgetCategoryAverage(category: try bridged($0.category), amount: $0.amount)
            }
            return BudgetEditContext(
                budget: try budgetOverview(edit.value1), averagePeriods: edit.value2.averagePeriods,
                averages: averages)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}
