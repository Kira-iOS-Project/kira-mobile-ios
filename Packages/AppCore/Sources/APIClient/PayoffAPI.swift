/** Rencana Pelunasan, Rencanaku and the payments on a debt. */
extension KiraAPI {
    /** Simulates a plan without saving it (`POST /api/payoff/simulate`). */
    package func simulatePayoff(method: PayoffMethodDTO, extraPayment: Int) async throws -> PayoffPlanDTO {
        let body = Components.Schemas.SimulatePayoff(method: try bridged(method), extraPayment: extraPayment)
        return try await client.simulatePayoff(body: .json(body)).plan()
    }

    /** Makes the plan the person's (`POST /api/payoff/plans`, Jadikan Rencanaku). */
    package func createPayoffPlan(method: PayoffMethodDTO, extraPayment: Int) async throws -> ActivePlanDTO {
        let body = Components.Schemas.CreatePayoffPlan(method: try bridged(method), extraPayment: extraPayment)
        return try await client.createPayoffPlan(body: .json(body)).plan()
    }

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

extension Operations.SimulatePayoff.Output {
    func plan() throws -> PayoffPlanDTO {
        switch self {
        case .ok(let response): return try PayoffPlanDTO(try response.body.json)
        case .badRequest(let response): throw try response.body.applicationProblemJson
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.CreatePayoffPlan.Output {
    func plan() throws -> ActivePlanDTO {
        switch self {
        case .created(let response): return try ActivePlanDTO(try response.body.json)
        case .badRequest(let response): throw try response.body.applicationProblemJson
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.GetActivePayoffPlan.Output {
    func plan() throws -> ActivePlanDTO {
        switch self {
        case .ok(let response): return try ActivePlanDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
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
        case .undocumented: throw AppProblem()
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
        case .undocumented: throw AppProblem()
        }
    }
}
