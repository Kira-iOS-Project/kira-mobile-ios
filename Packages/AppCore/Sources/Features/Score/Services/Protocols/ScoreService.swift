import Domain

/**
 What the Kira Score screens need from the API: `GET /score`, `GET /score/indicators/{key}` and
 `GET /score/history`.
 The integrator implements it with the generated client; each call throws an `AppProblem`.
 */
package protocol ScoreService: Sendable {
    /** The Kira Score, or nil before the health check (`SCORE_NOT_AVAILABLE`). */
    func score() async throws -> ScoreReport?

    /** One indicator in full. */
    func indicator(_ key: IndicatorKey) async throws -> IndicatorDetail

    /**
     Riwayat Kira Score over `range`, or nil before the health check (`SCORE_NOT_AVAILABLE`); a plan
     without it throws `PLAN_FEATURE_UNAVAILABLE`.
     */
    func history(_ range: ScoreHistoryRange) async throws -> ScoreHistory?

    /**
     Whether the plan includes Riwayat Kira Score (Kira Plus: "Kira Score Otomatis tiap Bulan"),
     from `GET /me`; true when that cannot be read, so the history's own answer decides.
     */
    func includesHistory() async -> Bool
}
