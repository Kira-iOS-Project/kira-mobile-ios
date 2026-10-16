import Foundation
import os

/** A clock the test moves by hand: the system boundary `now` replaced. */
final class TestClock: Sendable {
    private let current: OSAllocatedUnfairLock<Date>

    init(_ start: Date = Date(timeIntervalSince1970: 1_800_000_000)) {
        current = OSAllocatedUnfairLock(initialState: start)
    }

    /** The clock's time, to pass as `now`. */
    @Sendable func now() -> Date { current.withLock { $0 } }

    /** Moves the clock forward by `seconds`. */
    func advance(_ seconds: TimeInterval) {
        current.withLock { $0 = $0.addingTimeInterval(seconds) }
    }
}
