/** Rencana Pelunasan: the simulation, and making it the person's plan. */
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
}

extension Operations.SimulatePayoff.Output {
    func plan() throws -> PayoffPlanDTO {
        switch self {
        case .ok(let response): return try PayoffPlanDTO(try response.body.json)
        case .badRequest(let response): throw try response.body.applicationProblemJson
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
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
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
