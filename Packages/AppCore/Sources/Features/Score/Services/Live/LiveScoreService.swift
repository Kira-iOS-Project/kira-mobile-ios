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
}
