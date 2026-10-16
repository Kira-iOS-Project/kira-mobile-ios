/** The quota usage of the current period (tag Catat; CAT-05, CAT-09). */
extension KiraAPI {
    /** AI messages, receipts and voice seconds used against the plan, and the date they reset. */
    package func getUsage() async throws -> Usage {
        try await client.getUsage().usage()
    }
}

extension Operations.GetUsage.Output {
    func usage() throws -> Usage {
        switch self {
        case .ok(let response): return Usage(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
