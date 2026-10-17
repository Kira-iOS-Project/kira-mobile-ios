import Domain
import Foundation

@testable import Features

/**
 A `CheckInService` whose answers each test sets, and which records what it was asked. Each test
 makes its own; the models call it from the main actor.
 */
final class FakeCheckInService: CheckInService, @unchecked Sendable {
    var signalResult: Result<Void, any Error> = .success(())
    var scheduleResult: Result<CheckIn, any Error> = .success(CheckIn(id: "c-1"))
    var dueResult: Result<CheckIn?, any Error> = .success(nil)
    var seenResult: Result<Void, any Error> = .success(())
    var cancelResult: Result<Void, any Error> = .success(())

    private(set) var signals: [(level: CareSignalLevel, source: CareSignalSource)] = []
    private(set) var scheduled: [CheckInDelay] = []
    private(set) var seen: [String] = []
    private(set) var cancelled: [String] = []

    func recordSignal(_ level: CareSignalLevel, source: CareSignalSource) throws {
        signals.append((level, source))
        try signalResult.get()
    }

    func schedule(after delay: CheckInDelay) throws -> CheckIn {
        scheduled.append(delay)
        return try scheduleResult.get()
    }

    func due() throws -> CheckIn? { try dueResult.get() }

    func markSeen(id: String) throws {
        seen.append(id)
        try seenResult.get()
    }

    func cancel(id: String) throws {
        cancelled.append(id)
        try cancelResult.get()
    }
}

/** The on-device model's reading, as the test set it; counts how often it was asked. */
final class FakeCrisisRefiner: CrisisRefining, @unchecked Sendable {
    var assessment: CrisisAssessment?
    var knowsIndonesian = true
    private(set) var asked = 0

    init(_ assessment: CrisisAssessment?, knowsIndonesian: Bool = true) {
        self.assessment = assessment
        self.knowsIndonesian = knowsIndonesian
    }

    func supportsIndonesian() -> Bool { knowsIndonesian }

    func assess(_: String) -> CrisisAssessment? {
        asked += 1
        return assessment
    }
}
