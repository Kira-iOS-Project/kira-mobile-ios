import Domain

/** The health check and the Kira Score. */
extension KiraAPI {
    /** Saves the quiz, replacing the debts and the payday, and returns the score (`PUT /api/health-check`). */
    package func saveHealthCheck(_ answers: HealthCheckInputDTO) async throws -> ScoreReportDTO {
        try await client.saveHealthCheck(body: .json(try answers.body())).report()
    }

    /** The score (`GET /api/score`); 404 `SCORE_NOT_AVAILABLE` before the health check. */
    package func getScore() async throws -> ScoreReportDTO {
        try await client.getScore().report()
    }

    /** One indicator in detail (`GET /api/score/indicators/{key}`). */
    package func getScoreIndicator(_ key: IndicatorKey) async throws -> IndicatorDetailDTO {
        try await client.getScoreIndicator(path: .init(key: try bridged(key))).detail()
    }
}

extension Operations.SaveHealthCheck.Output {
    func report() throws -> ScoreReportDTO {
        switch self {
        case .ok(let response): return try ScoreReportDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.GetScore.Output {
    func report() throws -> ScoreReportDTO {
        switch self {
        case .ok(let response): return try ScoreReportDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.GetScoreIndicator.Output {
    func detail() throws -> IndicatorDetailDTO {
        switch self {
        case .ok(let response): return try IndicatorDetailDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
