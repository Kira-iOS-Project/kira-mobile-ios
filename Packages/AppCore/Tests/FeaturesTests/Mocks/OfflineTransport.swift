import APIClient
import Foundation
import HTTPTypes
import OpenAPIRuntime

/** The network boundary with no connection: every request fails before an answer comes. */
struct OfflineTransport: ClientTransport {
    func send(
        _: HTTPRequest, body _: HTTPBody?, baseURL _: URL, operationID _: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        throw URLError(.notConnectedToInternet)
    }
}

extension KiraAPI {
    /** A client that never gets an answer. */
    static var offline: KiraAPI {
        KiraAPI(serverURL: URL(string: "https://api.test") ?? URL(filePath: "/"), transport: OfflineTransport())
    }
}
