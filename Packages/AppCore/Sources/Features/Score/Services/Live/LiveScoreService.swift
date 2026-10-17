import APIClient
import Domain

/** The Kira Score screens' calls over the API client. */
package struct LiveScoreService: ScoreService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /score`; nil before the health check (`SCORE_NOT_AVAILABLE`). */
    package func score() async throws -> ScoreReport? {
        do {
            return try ScoreReport(try await api.getScore())
        } catch let problem as AppProblem where problem.knownCode == .scoreNotAvailable {
            return nil
        }
    }

    /** `GET /score/indicators/{key}`. */
    package func indicator(_ key: IndicatorKey) async throws -> IndicatorDetail {
        try IndicatorDetail(try await api.getScoreIndicator(key))
    }

    /** `GET /me`: whether the plan is Kira Plus; an unreadable answer leaves it to the feature's own. */
    package func includesPlus() async -> Bool {
        guard let account = try? await api.getMe() else { return true }
        return account.plan.id == .plus
    }

    /** `GET /score/history`; nil before the health check (`SCORE_NOT_AVAILABLE`). */
    package func history(_ range: ScoreHistoryRange) async throws -> ScoreHistory? {
        do {
            return try ScoreHistory(try await api.getScoreHistory(range))
        } catch let problem as AppProblem where problem.knownCode == .scoreNotAvailable {
            return nil
        }
    }
}
