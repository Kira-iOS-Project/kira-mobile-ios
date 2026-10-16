/** Beranda. */
extension KiraAPI {
    /** Beranda in its layout, with its numbers (`GET /api/home`). */
    package func getHome() async throws -> HomeSummary {
        try await client.getHome().summary()
    }
}

extension Operations.GetHome.Output {
    func summary() throws -> HomeSummary {
        switch self {
        case .ok(let response): return try HomeSummary(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
