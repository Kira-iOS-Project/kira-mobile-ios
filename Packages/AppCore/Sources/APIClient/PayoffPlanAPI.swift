/** Rencanaku: the active plan, moving it to another account, and the payments on a debt. */
extension KiraAPI {
    /** The active plan (`GET /api/payoff/plans/active`); 404 `PAYOFF_PLAN_NOT_FOUND` before one is made. */
    package func getActivePayoffPlan() async throws -> ActivePlanDTO {
        try await client.getActivePayoffPlan().plan()
    }

    /** Moves the plan to another account (`PATCH /api/payoff/plans/active`). */
    package func setPayoffFocus(debtId: String) async throws -> ActivePlanDTO {
        try await client.setPayoffFocus(body: .json(.init(focusDebtId: debtId))).plan()
    }

    /** Marks a payment on an account (`POST /api/debts/{id}/payments`, Tandai Sudah Bayar). */
    package func recordDebtPayment(debtId: String, amount: Int) async throws -> PaymentResultDTO {
        try await client.recordDebtPayment(path: .init(id: debtId), body: .json(.init(amount: amount))).result()
    }
}

extension Operations.GetActivePayoffPlan.Output {
    func plan() throws -> ActivePlanDTO {
        switch self {
        case .ok(let response): return try ActivePlanDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.SetPayoffFocus.Output {
    func plan() throws -> ActivePlanDTO {
        switch self {
        case .ok(let response): return try ActivePlanDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.RecordDebtPayment.Output {
    func result() throws -> PaymentResultDTO {
        switch self {
        case .ok(let response): return PaymentResultDTO(try response.body.json)
        case .badRequest(let response): throw try response.body.applicationProblemJson
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
