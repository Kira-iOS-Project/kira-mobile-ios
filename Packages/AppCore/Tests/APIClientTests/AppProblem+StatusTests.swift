/** How an answer without a problem body (a proxy's page, an empty 503) becomes a problem a screen can word. */
import Foundation
import Testing

@testable import APIClient

@Suite("AppProblem from a bare status")
struct AppProblemStatusTests {
    /** Calls `getMe` against a transport that answers `status` with `body` as `contentType`. */
    private func problem(status: Int, body: String? = nil, contentType: String? = nil) async -> AppProblem? {
        let (api, _) = KiraAPI.canned(status: status, json: body, contentType: contentType)
        do {
            _ = try await api.getMe()
            return nil
        } catch {
            return AppProblem(error)
        }
    }

    @Test("a proxy's HTML 404 reads as a missing route, with no UNKNOWN reference")
    func htmlNotFound() async {
        let problem = await problem(status: 404, body: "<html>Not Found</html>", contentType: "text/html")
        #expect(problem?.knownCode == .routeNotFound)
        #expect(problem?.showsReference == false)
    }

    @Test("an empty 503 and a JSON 502 read as Kira being unreachable")
    func serverDown() async {
        #expect(await problem(status: 503)?.knownCode == .metaHealthUnhealthy)
        #expect(await problem(status: 502, body: #"{"error":"bad gateway"}"#, contentType: "application/json")?.knownCode
            == .metaHealthUnhealthy)
    }

    @Test("a gateway timeout and any other bare status get their own code")
    func otherStatuses() async {
        #expect(await problem(status: 504)?.knownCode == .requestTimeout)
        #expect(await problem(status: 401, body: "nope", contentType: "text/plain")?.knownCode == .httpError)
    }
}
