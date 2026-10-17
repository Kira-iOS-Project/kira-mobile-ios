import Domain

/** Riwayat Kira Score as `GET /api/score/history` reports it (SKR-07, SKR-07b). */
package struct ScoreHistoryDTO: Hashable, Sendable {
    /** The score of one month. */
    package struct Point: Hashable, Sendable {
        /** `YYYY-MM`. */
        package let month: String
        /** The score that month. */
        package let score: Int
    }

    /** One indicator that moved since `previousMonth`. */
    package struct Change: Hashable, Sendable {
        /** Which indicator. */
        package let indicator: IndicatorKey
        /** The figure then, or nil for a snapshot taken before figures were kept. */
        package let fromLabel: String?
        /** The figure now. */
        package let toLabel: String
        /** The points then. */
        package let fromPoints: Int
        /** The points now. */
        package let toPoints: Int
    }

    /** The score now. */
    package let score: Int
    /** Its band. */
    package let band: ScoreBand
    /** Points since the latest monthly point before this month, or nil. */
    package let deltaFromPrevious: Int?
    /** That point's month, `YYYY-MM`, or nil. */
    package let previousMonth: String?
    /** One per month, oldest first. */
    package let points: [Point]
    /** The indicators that moved. */
    package let changes: [Change]
    /** The indicators that did not. */
    package let unchangedCount: Int

    init(_ history: Components.Schemas.ScoreHistory) throws {
        score = history.current.score
        band = try bridged(history.current.band)
        deltaFromPrevious = history.current.deltaFromPrevious
        previousMonth = history.current.previousMonth
        points = history.points.map { Point(month: $0.month, score: $0.score) }
        changes = try history.changes.map {
            Change(
                indicator: try bridged($0.indicator), fromLabel: $0.fromLabel, toLabel: $0.toLabel,
                fromPoints: $0.fromPoints, toPoints: $0.toPoints)
        }
        unchangedCount = history.unchangedCount
    }
}

extension KiraAPI {
    /**
     Riwayat Kira Score over `range` (`GET /api/score/history`); 403 `PLAN_FEATURE_UNAVAILABLE`
     outside Kira Plus, 404 `SCORE_NOT_AVAILABLE` before the health check.
     */
    package func getScoreHistory(_ range: ScoreHistoryRange) async throws -> ScoreHistoryDTO {
        let query: Operations.GetScoreHistory.Input.Query.RangePayload = try bridged(range)
        return try await client.getScoreHistory(query: .init(range: query)).history()
    }
}

extension Operations.GetScoreHistory.Output {
    func history() throws -> ScoreHistoryDTO {
        switch self {
        case .ok(let response): return try ScoreHistoryDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .forbidden(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
