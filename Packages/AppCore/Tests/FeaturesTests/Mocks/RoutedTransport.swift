import APIClient
import Foundation
import HTTPTypes
import OpenAPIRuntime

/**
 The network boundary of the live services' tests: it answers each "METHOD /path" with its canned
 status and body (unknown routes get 404 ROUTE_NOT_FOUND) and records what was sent, so the
 generated encoding and decoding run for real.
 */
actor RoutedTransport: ClientTransport {
    /** One canned answer. */
    struct Reply: Sendable {
        let status: Int
        let body: String?
        var contentType: String?
    }

    /** A request as the server reads it. */
    struct Sent: Sendable {
        let route: String
        let headers: HTTPFields
        let body: Data?

        /** The body as a JSON object, for assertions on what was sent. */
        var json: [String: JSONValue] {
            (try? JSONDecoder().decode([String: JSONValue].self, from: body ?? Data())) ?? [:]
        }
    }

    private let replies: [String: Reply]
    /** Every request received, in order. */
    private(set) var sent: [Sent] = []

    init(_ replies: [String: Reply]) {
        self.replies = replies
    }

    /** The routes called, in order. */
    var routes: [String] { sent.map(\.route) }

    func send(
        _ request: HTTPRequest, body: HTTPBody?, baseURL _: URL, operationID _: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let path = (request.path ?? "").split(separator: "?").first.map(String.init) ?? ""
        let route = "\(request.method.rawValue) \(path)"
        let data: Data? = if let body { try await Data(collecting: body, upTo: 1_000_000) } else { nil }
        sent.append(Sent(route: route, headers: request.headerFields, body: data))
        let reply = replies[route] ?? Reply(status: 404, body: problemJSON("ROUTE_NOT_FOUND"))
        var fields = HTTPFields()
        if reply.body != nil {
            fields[.contentType] =
                reply.contentType ?? (reply.status >= 400 ? "application/problem+json" : "application/json")
        }
        return (HTTPResponse(status: .init(code: reply.status), headerFields: fields), reply.body.map { HTTPBody($0) })
    }
}

/** A JSON value, to read back what a request sent. */
enum JSONValue: Decodable, Equatable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case array([JSONValue])
    case object([String: JSONValue])
    case null

    init(from decoder: any Decoder) throws {
        let value = try decoder.singleValueContainer()
        if value.decodeNil() {
            self = .null
        } else if let bool = try? value.decode(Bool.self) {
            self = .bool(bool)
        } else if let number = try? value.decode(Double.self) {
            self = .number(number)
        } else if let string = try? value.decode(String.self) {
            self = .string(string)
        } else if let array = try? value.decode([JSONValue].self) {
            self = .array(array)
        } else {
            self = .object(try value.decode([String: JSONValue].self))
        }
    }
}

extension KiraAPI {
    /** A client answered by `replies`, and the transport to inspect. */
    static func routed(_ replies: [String: RoutedTransport.Reply]) -> (api: KiraAPI, transport: RoutedTransport) {
        let transport = RoutedTransport(replies)
        return (KiraAPI(serverURL: URL(string: "https://api.test") ?? URL(filePath: "/"), transport: transport), transport)
    }
}

/** A 200 JSON answer. */
func ok(_ json: String, status: Int = 200) -> RoutedTransport.Reply {
    RoutedTransport.Reply(status: status, body: json)
}

/** A problem answer with `code`. */
func problem(_ code: String, status: Int = 400) -> RoutedTransport.Reply {
    RoutedTransport.Reply(status: status, body: problemJSON(code))
}

/** An empty answer, such as 204. */
func empty(_ status: Int = 204) -> RoutedTransport.Reply {
    RoutedTransport.Reply(status: status, body: nil)
}

/** A problem body with `code`, as the API answers a failure. */
func problemJSON(_ code: String) -> String {
    #"{"type":"\#(AppProblem.typeBase)\#(code)","title":"t","status":400,"code":"\#(code)","requestId":"r-1"}"#
}
