import Domain
import Observation

/**
 Latihan Menenangkan Diri (PED-11): breathe in 4, hold 4, breathe out 6, five rounds, counted second
 by second. Jeda stops the count and Lanjutkan resumes it; Selesai leaves at any time. Each step
 begins with a light tap of the phone, which the person can turn off.
 */
@MainActor
@Observable
package final class BreathingExerciseModel {
    /** The pattern, the board's 4-4-6 five times. */
    package let pattern: BreathingPattern
    /** Whole seconds counted so far. */
    package private(set) var elapsed = 0
    package private(set) var isPaused = false
    /** Whether a step begins with a tap of the phone. */
    package private(set) var hapticsOn = true

    private let tick: @Sendable () async throws -> Void
    private let haptic: @MainActor (BreathingPattern.Step) -> Void

    /**
     An exercise counted by `tick` (a one-second wait, cancelled when the screen goes) that taps the
     phone through `haptic` at each step.
     */
    package init(
        pattern: BreathingPattern = .calming, tick: @escaping @Sendable () async throws -> Void,
        haptic: @escaping @MainActor (BreathingPattern.Step) -> Void
    ) {
        self.pattern = pattern
        self.tick = tick
        self.haptic = haptic
    }

    /** Where the exercise is; nil once the five rounds are done. */
    package var moment: BreathingPattern.Moment? { pattern.moment(at: elapsed) }

    /** Whether the five rounds are done. */
    package var isFinished: Bool { moment == nil }

    /** Counts until the end, or until the screen goes away (the wait is cancelled). */
    package func run() async {
        if let moment { tap(moment.step) }
        while !isFinished {
            do { try await tick() } catch { return }
            guard !isPaused else { continue }
            let before = moment?.step
            elapsed += 1
            if let now = moment?.step, now != before { tap(now) }
        }
    }

    /** Jeda, or Lanjutkan. */
    package func togglePause() {
        isPaused.toggle()
    }

    /** Turns the taps on or off. */
    package func toggleHaptics() {
        hapticsOn.toggle()
    }

    private func tap(_ step: BreathingPattern.Step) {
        if hapticsOn { haptic(step) }
    }
}
