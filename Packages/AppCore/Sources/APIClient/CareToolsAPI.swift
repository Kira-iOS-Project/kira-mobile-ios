import Domain
import Foundation

/** Kira Peduli's tools: the debts a negotiation script is written to, and the safety plan. */
extension KiraAPI {
    /** The person's unpaid debts from the health check (`GET /api/debts`). */
    package func listDebts() async throws -> [DebtDTO] {
        try await client.listDebts().debts()
    }

    /** The saved safety plan (`GET /api/care/safety-plan`); 404 `CARE_SAFETY_PLAN_NOT_FOUND` when none. */
    package func getSafetyPlan() async throws -> SafetyPlanDTO {
        try await client.getSafetyPlan().plan()
    }

    /** Saves the whole safety plan (`PUT /api/care/safety-plan`) and returns it as stored. */
    package func saveSafetyPlan(_ plan: SafetyPlanDTO) async throws -> SafetyPlanDTO {
        try await client.saveSafetyPlan(body: .json(plan.input)).plan()
    }
}

extension Operations.ListDebts.Output {
    func debts() throws -> [DebtDTO] {
        switch self {
        case .ok(let response): return try response.body.json.debts.map(DebtDTO.init)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.GetSafetyPlan.Output {
    func plan() throws -> SafetyPlanDTO {
        switch self {
        case .ok(let response): return SafetyPlanDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.SaveSafetyPlan.Output {
    func plan() throws -> SafetyPlanDTO {
        switch self {
        case .ok(let response): return SafetyPlanDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
