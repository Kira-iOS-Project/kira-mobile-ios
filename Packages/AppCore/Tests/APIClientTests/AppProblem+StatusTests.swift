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

    @Test("a proxy's HTML 404 reads as Kira unreachable, with no reference")
    func htmlNotFound() async {
        let problem = await problem(status: 404, body: "<html>Not Found</html>", contentType: "text/html")
        #expect(problem == .serviceUnavailable)
        #expect(problem?.messageKey == "problem.serviceUnavailable")
        #expect(problem?.showsReference == false)
    }

    @Test("an empty 503, a JSON 502, a 504 and a 500 page read as Kira unreachable")
    func serverDown() async {
        #expect(await problem(status: 503) == .serviceUnavailable)
        let json = await problem(status: 502, body: #"{"error":"bad"}"#, contentType: "application/json")
        #expect(json == .serviceUnavailable)
        #expect(await problem(status: 504) == .serviceUnavailable)
        #expect(await problem(status: 500, body: "oops", contentType: "text/plain") == .serviceUnavailable)
    }

    @Test("a bare 429 asks to wait, a bare 401 is the session's, anything else is generic")
    func otherStatuses() async {
        let limited = await problem(status: 429)
        #expect(limited == .rateLimited)
        #expect(limited?.messageKey == "problem.rateLimited")
        #expect(await problem(status: 401, body: "nope", contentType: "text/plain")?.knownCode == .authUnauthenticated)
        let other = await problem(status: 418, body: "<p>teapot</p>", contentType: "text/html")
        #expect(other == AppProblem())
        #expect(other?.messageKey == "problem.unknown")
        #expect(other?.showsReference == false)
    }

    @Test("the reference shows only for an unknown code with a real request id")
    func referenceOnlyWithAnId() {
        #expect(AppProblem(code: "NEW_CODE", requestId: "0123456789").showsReference)
        #expect(!AppProblem(code: "NEW_CODE").showsReference)
        #expect(!AppProblem().showsReference)
        #expect(!AppProblem(code: "INTERNAL_ERROR", requestId: "r-1").showsReference)
        #expect(!AppProblem.connectionLost.showsReference)
    }
}
