import Domain
import Testing

@testable import Features

@MainActor
@Suite("BreathingExerciseModel")
struct BreathingExerciseModelTests {
    @MainActor final class Taps { var steps: [BreathingPattern.Step] = [] }

    private let short = BreathingPattern(inhale: 2, hold: 1, exhale: 2, rounds: 2)

    @Test("counts every second to the end, tapping at each new step")
    func runs() async {
        let taps = Taps()
        let model = BreathingExerciseModel(pattern: short, tick: {}) { taps.steps.append($0) }
        #expect(model.moment == BreathingPattern.Moment(round: 1, step: .inhale, secondsLeft: 2))
        await model.run()
        #expect(model.isFinished && model.elapsed == short.totalSeconds && model.moment == nil)
        #expect(taps.steps == [.inhale, .hold, .exhale, .inhale, .hold, .exhale])
    }

    @Test("Jeda stops the count until Lanjutkan")
    func pauses() async {
        let model = BreathingExerciseModel(pattern: short, tick: {}) { _ in }
        model.togglePause()
        let run = Task { await model.run() }
        for _ in 0..<50 { await Task.yield() }
        #expect(model.elapsed == 0 && model.isPaused)
        model.togglePause()
        await run.value
        #expect(model.isFinished)
    }

    @Test("taps nothing once turned off")
    func hapticsOff() async {
        let taps = Taps()
        let model = BreathingExerciseModel(pattern: short, tick: {}) { taps.steps.append($0) }
        model.toggleHaptics()
        #expect(!model.hapticsOn)
        await model.run()
        #expect(taps.steps.isEmpty)
        model.toggleHaptics()
        #expect(model.hapticsOn)
    }

    @Test("stops when the screen goes and the wait is cancelled")
    func cancelled() async {
        struct Cancelled: Error {}
        let model = BreathingExerciseModel(tick: { throw Cancelled() }) { _ in }
        #expect(model.pattern == .calming)
        await model.run()
        #expect(model.elapsed == 0 && !model.isFinished)
    }
}
