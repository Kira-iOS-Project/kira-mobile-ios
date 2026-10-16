import Domain

/** The health check and the Kira Score. */
extension KiraAPI {
    /** Saves the quiz, replacing the debts and the payday, and returns the score (`PUT /api/health-check`). */
    package func saveHealthCheck(_ answers: HealthCheckAnswers) async throws -> ScoreReport {
        try await client.saveHealthCheck(body: .json(try answers.body())).report()
    }

    /** The score (`GET /api/score`); 404 `SCORE_NOT_AVAILABLE` before the health check. */
    package func getScore() async throws -> ScoreReport {
        try await client.getScore().report()
    }

    /** One indicator in detail (`GET /api/score/indicators/{key}`). */
    package func getScoreIndicator(_ key: IndicatorKey) async throws -> IndicatorDetail {
        try await client.getScoreIndicator(path: .init(key: try bridged(key))).detail()
    }
}

extension Operations.SaveHealthCheck.Output {
    func report() throws -> ScoreReport {
        switch self {
        case .ok(let response): return try ScoreReport(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.GetScore.Output {
    func report() throws -> ScoreReport {
        switch self {
        case .ok(let response): return try ScoreReport(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.GetScoreIndicator.Output {
    func detail() throws -> IndicatorDetail {
        switch self {
        case .ok(let response): return try IndicatorDetail(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
