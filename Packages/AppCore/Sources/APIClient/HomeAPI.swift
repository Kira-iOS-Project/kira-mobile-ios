/** Beranda. */
extension KiraAPI {
    /** Beranda in its layout, with its numbers (`GET /api/home`). */
    package func getHome() async throws -> HomeDTO {
        try await client.getHome().summary()
    }
}

extension Operations.GetHome.Output {
    func summary() throws -> HomeDTO {
        switch self {
        case .ok(let response): return try HomeDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
