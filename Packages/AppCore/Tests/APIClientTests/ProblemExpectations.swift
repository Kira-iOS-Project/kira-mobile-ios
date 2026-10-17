/** Walks every error case of an operation's `Output` mapping against the canned transport. */
import Testing

@testable import APIClient

/**
 Runs `call` once per status in `statuses`, answered with a problem body, and expects that problem
 back; then once with a status the route does not list (418), which every route declares as a
 problem too (the spec's `default` response), and expects that problem back as well.
 */
func expectProblems(
    _ statuses: [Int], sourceLocation: SourceLocation = #_sourceLocation,
    _ call: @Sendable (KiraAPI) async throws -> Void
) async {
    for status in statuses {
        let (api, _) = KiraAPI.canned(status: status, json: problemJSON("HTTP_ERROR"))
        do {
            try await call(api)
            Issue.record("status \(status) returned instead of throwing", sourceLocation: sourceLocation)
        } catch let problem as AppProblem {
            #expect(problem.code == "HTTP_ERROR", "status \(status)", sourceLocation: sourceLocation)
        } catch {
            Issue.record(error, sourceLocation: sourceLocation)
        }
    }
    let (api, _) = KiraAPI.canned(status: 418, json: problemJSON("HTTP_ERROR"))
    let unlisted = AppProblem(type: AppProblem.typeBase + "HTTP_ERROR", code: "HTTP_ERROR", requestId: "r-1")
    await #expect(throws: unlisted, sourceLocation: sourceLocation) { try await call(api) }
}
