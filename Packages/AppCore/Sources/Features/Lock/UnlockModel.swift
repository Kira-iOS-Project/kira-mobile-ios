import Domain
import Foundation
import Observation

/**
 AKN-02 Kira Terkunci: the PIN typed on the lock screen's own keypad. A dot fills per digit; after
 six, Buka Kira checks them. A wrong PIN clears the dots and says how many tries are left; the
 fifth starts the 30-second pause, during which the keypad takes nothing.
 */
@MainActor @Observable
package final class UnlockModel {
    /** Where the lock screen is. */
    package enum Phase: Equatable, Sendable {
        /** Waiting for digits. */
        case entering
        /** The last PIN was wrong; `remainingAttempts` more before the pause. */
        case wrong(remainingAttempts: Int)
        /** Too many wrong tries: no PIN until `until`. */
        case paused(until: Date)
    }

    /** The phase of the screen. */
    package private(set) var phase: Phase = .entering
    /** How many digits are in (the dots); the digits themselves never leave the model. */
    package var filledCount: Int { digits.count }
    /** Whether all six digits are in, so Buka Kira shows in place of Lupa PIN. */
    package var isComplete: Bool { digits.count == PinPolicy.length }
    /** "Hai lagi, <name>": the account's name, or nil before one is known. */
    package let displayName: String?

    @ObservationIgnored private let lock: AppLockModel
    @ObservationIgnored private let now: @Sendable () -> Date
    private var digits = ""

    /** The lock screen of `lock`, greeting the owner of `email`. */
    package init(lock: AppLockModel, email: String?, now: @escaping @Sendable () -> Date = Date.init) {
        self.lock = lock
        self.now = now
        displayName = email.flatMap(DisplayName.from(email:))
        if let until = lock.pausedUntil() { phase = .paused(until: until) }
    }

    /** Adds `digit` (0–9) unless six are in or the lock is paused. */
    package func enter(_ digit: Int) {
        guard (0...9).contains(digit), !isComplete, !isPaused else { return }
        digits.append(String(digit))
    }

    /** Removes the last digit. */
    package func deleteLast() {
        guard !digits.isEmpty else { return }
        digits.removeLast()
    }

    /** Buka Kira: checks the six digits; the right PIN opens Kira. */
    package func open() {
        guard isComplete, !isPaused else { return }
        let check = lock.unlock(with: digits)
        digits = ""
        switch check {
        case .correct: phase = .entering
        case .wrong(let remaining): phase = .wrong(remainingAttempts: remaining)
        case .paused(let until): phase = .paused(until: until)
        }
    }

    /** Whole seconds left in the pause at `date` (for the countdown), 0 when not paused. */
    package func secondsLeft(at date: Date) -> Int {
        guard case .paused(let until) = phase else { return 0 }
        return max(0, Int(until.timeIntervalSince(date).rounded(.up)))
    }

    /** Ends the pause once its time has passed. */
    package func refreshPause() {
        guard case .paused(let until) = phase, until <= now() else { return }
        phase = .entering
    }

    private var isPaused: Bool {
        refreshPause()
        if case .paused = phase { return true }
        return false
    }
}
