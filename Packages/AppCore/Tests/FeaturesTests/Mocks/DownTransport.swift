import APIClient
import Foundation
import HTTPTypes
import OpenAPIRuntime

/**
 The network boundary with the server unreachable: every request fails with the `URLError` the
 system transport throws when nothing listens on the port, so the generated client wraps it in its
 `ClientError` just as it does on a device with the backend down.
 */
struct DownTransport: ClientTransport {
    func send(
        _: HTTPRequest, body _: HTTPBody?, baseURL _: URL, operationID _: String
    ) throws -> (HTTPResponse, HTTPBody?) {
        throw URLError(.cannotConnectToHost)
    }
}

extension KiraAPI {
    /** A client whose server cannot be reached. */
    static var down: KiraAPI {
        KiraAPI(serverURL: URL(string: "https://api.test") ?? URL(filePath: "/"), transport: DownTransport())
    }
}
