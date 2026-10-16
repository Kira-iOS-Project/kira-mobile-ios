/** Beasiswa Kira: eligibility, applying and withdrawing. */
extension KiraAPI {
    /** Eligibility, places and the latest application (`GET /api/scholarship`). */
    package func getScholarship() async throws -> ScholarshipStatus {
        try await client.getScholarship().status()
    }

    /** Applies with at least one situation and an optional story (`POST /api/scholarship/applications`). */
    package func applyForScholarship(
        situations: [HardshipSituation], story: String?
    ) async throws -> ScholarshipApplication {
        let body = Components.Schemas.ScholarshipApplicationRequest(
            situations: try situations.map { try bridged($0) }, story: story)
        return try await client.applyForScholarship(body: .json(body)).application()
    }

    /** Withdraws the open application (`DELETE /api/scholarship/applications/current`). */
    package func withdrawScholarshipApplication() async throws {
        try await client.withdrawScholarshipApplication().done()
    }
}

extension Operations.GetScholarship.Output {
    func status() throws -> ScholarshipStatus {
        switch self {
        case .ok(let response): return try ScholarshipStatus(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.ApplyForScholarship.Output {
    func application() throws -> ScholarshipApplication {
        switch self {
        case .created(let response): return try ScholarshipApplication(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .conflict(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.WithdrawScholarshipApplication.Output {
    func done() throws {
        switch self {
        case .noContent: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
