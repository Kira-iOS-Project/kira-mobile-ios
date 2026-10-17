/**
 Rencana Keselamatanku on the board's plan whose save never goes through: the API refuses it with
 `problem`, or the connection is lost (`AppProblem.connectionLost`). For the failure dialog in
 previews and `-KiraScreen safetyPlanFailing`.
 */
import APIClient
import Domain
import Features

struct FailingSafetyPlanService: CareToolsService {
    let problem: AppProblem

    func displayName() -> String { "Dinda" }

    func debts() -> [CareDebt] { [] }

    func safetyPlan() -> SafetyPlan? { PreviewCareToolsService.samplePlan }

    func saveSafetyPlan(_: SafetyPlan) throws -> SafetyPlan { throw problem }
}
