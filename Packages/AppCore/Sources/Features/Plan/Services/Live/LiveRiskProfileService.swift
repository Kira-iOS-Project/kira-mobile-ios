import APIClient
import Domain

/** The risk profile over the API client: the server scores the answers; the app only sends and reads them. */
package struct LiveRiskProfileService: RiskProfileService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /risk-profile`: nil while every field is null (before the first quiz) or the profile is one this app does not know. */
    package func savedProfile() async throws -> SavedRiskProfile? {
        let saved = try await api.getRiskProfile()
        guard let profile = saved.profile.flatMap(RiskProfile.init(rawValue:)) else { return nil }
        return SavedRiskProfile(profile: profile, answers: RiskAnswers(saved.answers ?? []))
    }

    /** `PUT /risk-profile`: an answer the server left without a profile reads as a generic problem. */
    package func saveRiskProfile(answers: [Int]) async throws -> RiskProfile {
        let saved = try await api.saveRiskProfile(answers: answers)
        guard let profile = saved.profile.flatMap(RiskProfile.init(rawValue:)) else { throw AppProblem() }
        return profile
    }
}
