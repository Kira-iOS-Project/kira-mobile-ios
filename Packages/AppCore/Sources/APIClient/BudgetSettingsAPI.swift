import Domain

/** Atur Budget's calls (UNG-05): what it opens with (`getCurrentBudget`) and Simpan Budget (`saveCurrentBudget`). */
extension KiraAPI {
    /** `GET /budgets/current` as Atur Budget reads it. */
    package func budgetSetup() async throws -> BudgetSetup {
        try await client.getCurrentBudget().setup()
    }

    /** `PUT /budgets/current`: the payday and every category's amount, each once. 422 on a bad range. */
    package func saveBudget(_ plan: BudgetPlan) async throws {
        let allocations = try plan.allocations.sorted { $0.key.rawValue < $1.key.rawValue }.map {
            Components.Schemas.SaveBudget.AllocationsPayloadPayload(category: try bridged($0.key), amount: $0.value)
        }
        let payday = Components.Schemas.SaveBudget.PaydayPayload(
            day: plan.payday.day, endOfMonth: plan.payday.isEndOfMonth)
        try await client.saveCurrentBudget(body: .json(.init(allocations: allocations, payday: payday))).saved()
    }
}

extension Operations.GetCurrentBudget.Output {
    func setup() throws -> BudgetSetup {
        switch self {
        case .ok(let response): try budgetSetup(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.SaveCurrentBudget.Output {
    func saved() throws {
        switch self {
        case .ok: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

/** The current budget as Atur Budget's setup: payday, amounts, averages, instalments and the goal's deposit. */
func budgetSetup(_ row: Components.Schemas.CurrentBudget) throws -> BudgetSetup {
    let requested = row.payday.requested
    let payday = requested.endOfMonth ? Payday.endOfMonth : Payday(day: requested.day ?? Payday.defaultDay)
    let allocations = try row.allocations.map { (try bridged($0.category) as TransactionCategory, $0.amount) }
    let averages = try row.averages.map { (try bridged($0.category) as TransactionCategory, $0.amount) }
    return BudgetSetup(
        income: row.income, payday: payday,
        allocations: Dictionary(allocations, uniquingKeysWith: { _, last in last }),
        averages: Dictionary(averages, uniquingKeysWith: { _, last in last }),
        instalments: row.instalmentsMonthly, goalDeposit: row.goalPost?.monthlyDeposit)
}
