/**
 A request that never got an answer (no network, a timeout on the device, an unreachable server)
 is not a problem the API sent, so it has no code; screens still need to say what happened rather
 than show the generic message with an "UNKNOWN" reference. It travels as an `AppProblem` whose
 `type` is this app's own, which no API code ever resolves from.
 */
import Foundation
import OpenAPIRuntime

extension AppProblem {
    /** The `type` of a request that got no answer; never one of the API's types. */
    static let connectionLostType = "urn:kira:connection-lost"

    /** The problem of a request that never got an answer. */
    package static let connectionLost = AppProblem(type: connectionLostType)

    /** Whether the request never got an answer. */
    package var isConnectionLoss: Bool { type == Self.connectionLostType }

    /** Whether a screen shows the reference: for a problem this app does not know, not for a lost connection. */
    package var showsReference: Bool { knownCode == nil && !isConnectionLoss }

    /**
     The problem an error from a call stands for: the API's own problem (also when a middleware threw
     it and the client wrapped it), connection loss for a transport failure, else the generic one.
     */
    package init(_ error: any Error) {
        let cause = (error as? ClientError)?.underlyingError ?? error
        if let problem = cause as? AppProblem {
            self = problem
        } else if cause is URLError {
            self = .connectionLost
        } else {
            self = AppProblem()
        }
    }
}
