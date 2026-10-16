/** The system boundary of every API test: a transport that answers one canned response. */
import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@testable import APIClient

/** One request the client sent, as the server would read it. */
struct RecordedRequest: Sendable {
    /** The spec's operationId, such as `requestSignInCode`: which route was called. */
    let operation: String
    /** GET, POST, PUT, PATCH or DELETE. */
    let method: HTTPRequest.Method
    /** The path with its query; tests read path parameters and queries from it. */
    let path: String
    /** The request's headers. */
    let headers: HTTPFields
    /** The body, or nil when there is none. */
    let body: Data?

    /** The body decoded as `type`, for assertions on what was sent. */
    func decoded<Body: Decodable>(_ type: Body.Type) throws -> Body {
        try JSONDecoder().decode(type, from: body ?? Data())
    }

    /** The body as text. */
    var text: String { body.flatMap { String(bytes: $0, encoding: .utf8) } ?? "" }
}

/**
 Answers every request with `status` and `body` (JSON by default; a 4xx or 5xx JSON body goes out
 as `application/problem+json`, as the API sends it) and records the requests, so a test runs the
 generated encoding and decoding for real.
 */
actor CannedTransport: ClientTransport {
    private let status: Int
    private let body: Data?
    private let contentType: String
    /** Every request received, in order. */
    private(set) var requests: [RecordedRequest] = []

    init(status: Int, body: String? = nil, contentType: String? = nil) {
        self.status = status
        self.body = body.map { Data($0.utf8) }
        self.contentType =
            contentType ?? (status >= 400 ? "application/problem+json" : "application/json")
    }

    /** The only request received. */
    var request: RecordedRequest? { requests.last }

    func send(
        _ request: HTTPRequest, body: HTTPBody?, baseURL _: URL, operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let sent: Data? = if let body { try await Data(collecting: body, upTo: 1_000_000) } else { nil }
        requests.append(
            RecordedRequest(
                operation: operationID,
                method: request.method, path: request.path ?? "", headers: request.headerFields, body: sent))
        var fields = HTTPFields()
        if self.body != nil { fields[.contentType] = contentType }
        let response = HTTPResponse(status: .init(code: status), headerFields: fields)
        return (response, self.body.map { HTTPBody($0) })
    }
}

extension KiraAPI {
    /** A client whose every call is answered with `status` and `json`, and the transport to inspect. */
    static func canned(
        status: Int = 200, json: String? = nil, contentType: String? = nil
    ) -> (api: KiraAPI, transport: CannedTransport) {
        let transport = CannedTransport(status: status, body: json, contentType: contentType)
        let api = KiraAPI(serverURL: URL(string: "https://api.test") ?? URL(filePath: "/"), transport: transport)
        return (api, transport)
    }
}

/** A problem body with `code`, as the API answers a failure. */
func problemJSON(_ code: String) -> String {
    #"{"type":"\#(AppProblem.typeBase)\#(code)","title":"t","status":400,"code":"\#(code)","requestId":"r-1"}"#
}

/**
 Runs `call` once per status in `statuses`, answered with a problem body, and expects that problem
 back; then once with an undocumented status (418), and expects the generic `AppProblem()`. This
 walks every error case of an operation's `Output` mapping.
 */
func expectProblems(
    _ statuses: [Int], sourceLocation: SourceLocation = #_sourceLocation,
    _ call: @Sendable (KiraAPI) async throws -> Void
) async {
    for status in statuses {
        let (api, _) = KiraAPI.canned(status: status, json: problemJSON("HTTP_ERROR"))
        await #expect(throws: AppProblem.self, sourceLocation: sourceLocation) { try await call(api) }
        do {
            try await call(api)
        } catch let problem as AppProblem {
            #expect(problem.code == "HTTP_ERROR", "status \(status)", sourceLocation: sourceLocation)
        } catch {
            Issue.record(error, sourceLocation: sourceLocation)
        }
    }
    let (api, _) = KiraAPI.canned(status: 418, json: problemJSON("HTTP_ERROR"))
    await #expect(throws: AppProblem(), sourceLocation: sourceLocation) { try await call(api) }
}
