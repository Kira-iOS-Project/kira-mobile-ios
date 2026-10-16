/** The system boundary of the live services' tests: a transport that answers one canned response. */
import APIClient
import Foundation
import HTTPTypes
import OpenAPIRuntime

/** One request the client sent, as the server would read it. */
struct CannedRequest: Sendable {
    /** GET, POST, PUT, PATCH or DELETE. */
    let method: HTTPRequest.Method
    /** The path with its query. */
    let path: String
    /** The body as text, empty when there is none. */
    let text: String

    /** The body without whitespace: the client pretty-prints JSON, so a test matches `"key":"value"`. */
    var compact: String { text.filter { !$0.isWhitespace } }
}

/**
 Answers every request with `status` and `body` (JSON, or problem JSON from 400 on) and records the
 requests, so a live service runs the generated encoding and decoding for real.
 */
actor CannedTransport: ClientTransport {
    private let status: Int
    private let body: Data?
    /** Every request received, in order. */
    private(set) var requests: [CannedRequest] = []

    init(status: Int, body: String?) {
        self.status = status
        self.body = body.map { Data($0.utf8) }
    }

    /** The last request received. */
    var request: CannedRequest? { requests.last }

    func send(
        _ request: HTTPRequest, body: HTTPBody?, baseURL _: URL, operationID _: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let sent: Data? = if let body { try await Data(collecting: body, upTo: 1_000_000) } else { nil }
        let text = sent.flatMap { String(bytes: $0, encoding: .utf8) } ?? ""
        requests.append(CannedRequest(method: request.method, path: request.path ?? "", text: text))
        var fields = HTTPFields()
        if self.body != nil { fields[.contentType] = status >= 400 ? "application/problem+json" : "application/json" }
        return (HTTPResponse(status: .init(code: status), headerFields: fields), self.body.map { HTTPBody($0) })
    }
}

extension KiraAPI {
    /** A client whose every call is answered with `status` and `json`, and the transport to inspect. */
    static func canned(status: Int = 200, json: String? = nil) -> (api: KiraAPI, transport: CannedTransport) {
        let transport = CannedTransport(status: status, body: json)
        return (
            KiraAPI(serverURL: URL(string: "https://api.test") ?? URL(filePath: "/"), transport: transport), transport
        )
    }
}
