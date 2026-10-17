/**
 Problems this app makes itself, for answers that carry no problem from the API: a request that
 never got an answer (no network, a timeout on the device), or a status without a problem body (a
 proxy's HTML 404, an empty 503). Screens still need to say what happened rather than show the
 generic message. Each travels as an `AppProblem` whose `type` is this app's own, which no API
 code ever resolves from.
 */
import Foundation
import HTTPTypes
import OpenAPIRuntime

extension AppProblem {
    /** The `type` of a request that got no answer; never one of the API's types. */
    static let connectionLostType = "urn:kira:connection-lost"
    /** The `type` of a 404 or 5xx answered without a problem body: Kira cannot be reached. */
    static let serviceUnavailableType = "urn:kira:service-unavailable"
    /** The `type` of a 429 answered without a problem body. */
    static let rateLimitedType = "urn:kira:rate-limited"

    /** The problem of a request that never got an answer. */
    package static let connectionLost = AppProblem(type: connectionLostType)
    /** The problem of a 404 or 5xx without a problem body. */
    package static let serviceUnavailable = AppProblem(type: serviceUnavailableType)
    /** The problem of a 429 without a problem body. */
    package static let rateLimited = AppProblem(type: rateLimitedType)

    /** Whether the request never got an answer. */
    package var isConnectionLoss: Bool { type == Self.connectionLostType }

    /** The catalog key of a problem this app made itself, or nil for the API's own. */
    var clientMessageKey: String? {
        switch type {
        case Self.connectionLostType: "problem.connection"
        case Self.serviceUnavailableType: "problem.serviceUnavailable"
        case Self.rateLimitedType: "problem.rateLimited"
        default: nil
        }
    }

    /**
     Whether a screen shows the reference: only for a problem this app does not know that carries
     a real request id. Never a placeholder such as "UNKNOWN".
     */
    package var showsReference: Bool {
        knownCode == nil && clientMessageKey == nil && !(requestId ?? "").isEmpty
    }

    /**
     The problem an error from a call stands for: the API's own problem (also when a middleware threw
     it and the client wrapped it), connection loss for a transport failure, the status's problem
     when an answer came without a problem body, else the generic one.
     */
    package init(_ error: any Error) {
        let client = error as? ClientError
        let cause = client?.underlyingError ?? error
        if let problem = cause as? AppProblem {
            self = problem
        } else if cause is URLError {
            self = .connectionLost
        } else if let status = client?.response?.status.code {
            self = Self.answered(status: status)
        } else {
            self = AppProblem()
        }
    }

    /**
     The problem of a status answered without a problem body: 401 is the session's own path, 429
     asks to wait, a 404 or any 5xx means Kira cannot be reached, and anything else is generic.
     */
    static func answered(status: Int) -> AppProblem {
        switch status {
        case 401: AppProblem(code: ProblemCode.authUnauthenticated.rawValue)
        case 429: .rateLimited
        case 404, 500...599: .serviceUnavailable
        default: AppProblem()
        }
    }
}
