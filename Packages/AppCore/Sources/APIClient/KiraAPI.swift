import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/**
 The Kira API as the app calls it: one `package` function per operation, in an extension per tag
 (`AuthAPI.swift`, `AccountAPI.swift`, …). Each returns this target's own values and throws an
 `AppProblem` for every failure the API answers, so a screen never sees a generated type.
 */
package struct KiraAPI: Sendable {
    /** The generated client; internal to this target. */
    let client: Client

    /**
     A client for the API at `serverURL` (the host root: every path already starts with `/api`).
     `middlewares` run in order on every request, such as the bearer-token middleware; `transport`
     is `URLSession` outside tests.
     */
    package init(
        serverURL: URL,
        middlewares: [any ClientMiddleware] = [],
        transport: any ClientTransport = URLSessionTransport()
    ) {
        client = Client(
            serverURL: serverURL,
            configuration: Configuration(dateTranscoder: .iso8601WithFractionalSeconds),
            transport: transport,
            middlewares: middlewares
        )
    }
}
