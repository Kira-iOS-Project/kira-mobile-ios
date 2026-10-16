import Domain

/**
 Kira Peduli's calls from the Catat chat (CONTRACT-KOM-PED "Care"): the crisis signal (PED-02) and
 the check-in (PED-05, PED-06). Every call throws an `AppProblem` for an answer the API refused, and
 any other error when the request did not arrive.
 */
package protocol CheckInService: Sendable {
    /** `POST /care/signals`: that a signal happened, its level and source; never the message. */
    func recordSignal(_ level: CareSignalLevel, source: CareSignalSource) async throws
    /** `POST /care/check-ins`: greet again after `delay`, replacing a pending check-in. */
    func schedule(after delay: CheckInDelay) async throws -> CheckIn
    /** `GET /care/check-ins/due`: the pending check-in whose time has come, or nil. */
    func due() async throws -> CheckIn?
    /** `POST /care/check-ins/{id}/seen`: the greeting was shown. */
    func markSeen(id: String) async throws
    /** `DELETE /care/check-ins/{id}`: the person no longer wants the greeting. */
    func cancel(id: String) async throws
}
