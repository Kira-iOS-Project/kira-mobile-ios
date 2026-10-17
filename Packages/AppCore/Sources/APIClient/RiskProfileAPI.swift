import Foundation

/** The risk profile (REN-06, REN-07): the server scores the five answers and keeps them. */
extension KiraAPI {
    /** The saved profile (`GET /api/risk-profile`); every field is null before the first quiz. */
    package func getRiskProfile() async throws -> RiskProfileDTO {
        try await client.getRiskProfile().profile()
    }

    /** Saves the five 0-based answers (`PUT /api/risk-profile`) and returns the profile the server computed. */
    package func saveRiskProfile(answers: [Int]) async throws -> RiskProfileDTO {
        try await client.saveRiskProfile(body: .json(.init(answers: answers))).profile()
    }
}

/** A risk profile as the API sends it: the profile's raw value and the answers, both null before the quiz. */
package struct RiskProfileDTO: Hashable, Sendable {
    /** "conservative", "moderate" or "aggressive"; nil before the quiz. */
    package let profile: String?
    /** The five answers; nil before the quiz. */
    package let answers: [Int]?

    init(_ body: Components.Schemas.RiskProfile) {
        profile = body.profile.flatMap { $0 == ._empty_ ? nil : $0.rawValue }
        answers = body.answers
    }
}

extension Operations.GetRiskProfile.Output {
    func profile() throws -> RiskProfileDTO {
        switch self {
        case .ok(let response): return RiskProfileDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.SaveRiskProfile.Output {
    func profile() throws -> RiskProfileDTO {
        switch self {
        case .ok(let response): return RiskProfileDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
