/**
 Latihan Menenangkan Diri (PED-11): breathe in for 4, hold for 4, breathe out for 6, five rounds.
 Where the exercise is follows from the whole seconds since it started, so a pause only stops the
 count and the step shown is never out of step with the time.
 */
package struct BreathingPattern: Hashable, Sendable {
    /** A step of one round. */
    package enum Step: CaseIterable, Hashable, Sendable {
        /** Tarik napas: the circle grows. */
        case inhale
        /** Tahan: the circle holds. */
        case hold
        /** Hembuskan: the circle shrinks. */
        case exhale
    }

    /** Where the exercise is at a given second. */
    package struct Moment: Hashable, Sendable {
        /** The round, from 1. */
        package let round: Int
        /** The step of the round. */
        package let step: Step
        /** The seconds left in the step, from its length down to 1. */
        package let secondsLeft: Int

        /** A moment of the given round and step. */
        package init(round: Int, step: Step, secondsLeft: Int) {
            self.round = round
            self.step = step
            self.secondsLeft = secondsLeft
        }
    }

    /** Seconds to breathe in. */
    package let inhale: Int
    /** Seconds to hold. */
    package let hold: Int
    /** Seconds to breathe out. */
    package let exhale: Int
    /** How many rounds. */
    package let rounds: Int

    /** The board's 4-4-6, five rounds. */
    package static let calming = BreathingPattern(inhale: 4, hold: 4, exhale: 6, rounds: 5)

    /** A pattern of the given lengths, in seconds. */
    package init(inhale: Int, hold: Int, exhale: Int, rounds: Int) {
        self.inhale = inhale
        self.hold = hold
        self.exhale = exhale
        self.rounds = rounds
    }

    /** The seconds of one round. */
    package var roundSeconds: Int { inhale + hold + exhale }

    /** The seconds of the whole exercise. */
    package var totalSeconds: Int { roundSeconds * rounds }

    /** The length of `step`, in seconds. */
    package func seconds(of step: Step) -> Int {
        switch step {
        case .inhale: inhale
        case .hold: hold
        case .exhale: exhale
        }
    }

    /** Where the exercise is after `elapsed` whole seconds; nil once it is over. */
    package func moment(at elapsed: Int) -> Moment? {
        guard elapsed >= 0, elapsed < totalSeconds else { return nil }
        let round = elapsed / roundSeconds + 1
        let into = elapsed % roundSeconds
        if into < inhale { return Moment(round: round, step: .inhale, secondsLeft: inhale - into) }
        if into < inhale + hold { return Moment(round: round, step: .hold, secondsLeft: inhale + hold - into) }
        return Moment(round: round, step: .exhale, secondsLeft: roundSeconds - into)
    }
}
