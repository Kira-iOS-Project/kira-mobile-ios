/** AuthMiddleware: signing, the one retry after 401, and through the generated client. */
import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@testable import APIClient

/** A token source with a fixed current token and a fixed renewal, counting renewals. */
private actor Tokens: BearerTokenSource {
    let current: String?
    let renewed: String?
    private(set) var renewals: [String] = []

    init(current: String?, renewed: String? = nil) {
        self.current = current
        self.renewed = renewed
    }

    func bearerToken() -> String? { current }

    func renewedBearerToken(replacing rejected: String) -> String? {
        renewals.append(rejected)
        return renewed
    }
}

/** The transport side of the middleware: answers with `statuses` in turn and records each request. */
private actor Server {
    private var statuses: [HTTPResponse.Status]
    private(set) var authorizations: [String?] = []

    init(_ statuses: [HTTPResponse.Status]) { self.statuses = statuses }

    func answer(_ request: HTTPRequest) -> (HTTPResponse, HTTPBody?) {
        authorizations.append(request.headerFields[.authorization])
        let status = statuses.isEmpty ? .ok : statuses.removeFirst()
        return (HTTPResponse(status: status), HTTPBody("{\"status\":\"ok\",\"database\":\"healthy\"}"))
    }
}

/** A canned `ClientTransport` over `Server`, so the generated client runs for real. */
private struct CannedTransport: ClientTransport {
    let server: Server

    func send(_ request: HTTPRequest, body _: HTTPBody?, baseURL _: URL, operationID _: String) async throws -> (
        HTTPResponse, HTTPBody?
    ) {
        var response = await server.answer(request)
        response.0.headerFields[.contentType] = "application/json"
        return response
    }
}

private let url = URL(string: "https://api.test")
private let request = HTTPRequest(method: .get, scheme: "https", authority: "api.test", path: "/me")

private func run(
    _ middleware: AuthMiddleware, server: Server, operation: String = "getMe", body: HTTPBody? = nil
) async throws -> HTTPResponse.Status {
    let base = try #require(url)
    let next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?) = { request, _, _ in
        await server.answer(request)
    }
    let (response, _) = try await middleware.intercept(
        request, body: body, baseURL: base, operationID: operation, next: next)
    return response.status
}

@Suite("AuthMiddleware")
struct AuthMiddlewareTests {
    @Test("leaves the public operations unsigned")
    func publicOperation() async throws {
        let server = Server([.ok])
        let middleware = AuthMiddleware(tokens: Tokens(current: "a"))
        let status = try await run(middleware, server: server, operation: "refreshSession")
        #expect(status == .ok)
        #expect(await server.authorizations == [nil])
    }

    @Test("sends unsigned when signed out")
    func signedOut() async throws {
        let server = Server([.ok])
        _ = try await run(AuthMiddleware(tokens: Tokens(current: nil)), server: server)
        #expect(await server.authorizations == [nil])
    }

    @Test("signs with the bearer token")
    func signs() async throws {
        let server = Server([.ok])
        let tokens = Tokens(current: "a")
        #expect(try await run(AuthMiddleware(tokens: tokens), server: server) == .ok)
        #expect(await server.authorizations == ["Bearer a"])
        #expect(await tokens.renewals.isEmpty)
    }

    @Test("on 401 renews once and sends again")
    func retries() async throws {
        let server = Server([.unauthorized, .ok])
        let tokens = Tokens(current: "a", renewed: "b")
        #expect(try await run(AuthMiddleware(tokens: tokens), server: server) == .ok)
        #expect(await server.authorizations == ["Bearer a", "Bearer b"])
        #expect(await tokens.renewals == ["a"])
    }

    @Test("returns a second 401 as it is")
    func secondRefusal() async throws {
        let server = Server([.unauthorized, .unauthorized])
        let status = try await run(AuthMiddleware(tokens: Tokens(current: "a", renewed: "b")), server: server)
        #expect(status == .unauthorized)
        #expect(await server.authorizations.count == 2)
    }

    @Test("returns the 401 when the session has ended")
    func sessionEnded() async throws {
        let server = Server([.unauthorized])
        let status = try await run(AuthMiddleware(tokens: Tokens(current: "a")), server: server)
        #expect(status == .unauthorized)
        #expect(await server.authorizations == ["Bearer a"])
    }

    @Test("never sends a read-once body twice")
    func singleBody() async throws {
        let server = Server([.unauthorized])
        let body = HTTPBody([UInt8]("{}".utf8), length: .known(2), iterationBehavior: .single)
        let tokens = Tokens(current: "a", renewed: "b")
        let status = try await run(AuthMiddleware(tokens: tokens), server: server, body: body)
        #expect(status == .unauthorized)
        #expect(await tokens.renewals.isEmpty)
    }

    @Test("signs and retries the generated client's requests")
    func generatedClient() async throws {
        let server = Server([.unauthorized, .ok])
        let middleware = AuthMiddleware(tokens: Tokens(current: "a", renewed: "b"), publicOperations: [])
        let client = Client(
            serverURL: try #require(url), transport: CannedTransport(server: server), middlewares: [middleware])
        let output = try await client.getHealth()
        #expect(try output.ok.body.json.status == .ok)
        #expect(await server.authorizations == ["Bearer a", "Bearer b"])
    }
}
