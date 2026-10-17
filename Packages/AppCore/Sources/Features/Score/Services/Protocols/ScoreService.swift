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

    /** Riwayat Kira Score over `range`, or nil before the health check (`SCORE_NOT_AVAILABLE`). */
    func history(_ range: ScoreHistoryRange) async throws -> ScoreHistory?
}
