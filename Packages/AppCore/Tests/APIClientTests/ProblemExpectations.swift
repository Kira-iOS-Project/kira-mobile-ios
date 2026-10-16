/** Walks every error case of an operation's `Output` mapping against the canned transport. */
import Testing

@testable import APIClient

/**
 Runs `call` once per status in `statuses`, answered with a problem body, and expects that problem
 back; then once with an undocumented status (418), and expects the generic `AppProblem()`.
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
    await #expect(throws: AppProblem(), sourceLocation: sourceLocation) { try await call(api) }
}
