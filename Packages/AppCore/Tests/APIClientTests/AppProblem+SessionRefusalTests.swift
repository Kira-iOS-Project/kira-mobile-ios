/** Which errors end the session: the API refusing it, never an API that did not answer. */
import Foundation
import Testing

@testable import APIClient

@Suite("AppProblem session refusal")
struct AppProblemSessionRefusalTests {
    /** The error `refreshSession` throws when the API answers `status` with `body` as `contentType`. */
    private func refreshError(status: Int, body: String? = nil, contentType: String? = nil) async -> (any Error)? {
        let (api, _) = KiraAPI.canned(status: status, json: body, contentType: contentType)
        do {
            _ = try await api.refreshSession(refreshToken: "r")
            return nil
        } catch {
            return error
        }
    }

    @Test("a refused refresh token or session is a refusal, with or without a problem body")
    func refusals() async throws {
        let invalid = try #require(await refreshError(status: 401, body: problemJSON("AUTH_REFRESH_INVALID")))
        #expect(AppProblem.isSessionRefusal(invalid))
        #expect(AppProblem.isSessionRefusal(AppProblem(code: "AUTH_UNAUTHENTICATED")))
        let bare = try #require(await refreshError(status: 401, body: "<html>401</html>", contentType: "text/html"))
        #expect(AppProblem.isSessionRefusal(bare))
        let empty = try #require(await refreshError(status: 401))
        #expect(AppProblem.isSessionRefusal(empty))
    }

    @Test("a lost connection, a server error or any other problem is not")
    func notRefusals() async throws {
        #expect(!AppProblem.isSessionRefusal(URLError(.notConnectedToInternet)))
        let down = try #require(await refreshError(status: 503))
        #expect(!AppProblem.isSessionRefusal(down))
        let invalid = try #require(await refreshError(status: 422, body: problemJSON("VALIDATION_FAILED")))
        #expect(!AppProblem.isSessionRefusal(invalid))
    }
}
