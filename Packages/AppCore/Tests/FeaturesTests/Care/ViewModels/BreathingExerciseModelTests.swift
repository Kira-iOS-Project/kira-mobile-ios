import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("BreathingExerciseModel")
struct BreathingExerciseModelTests {
    @MainActor final class Taps { var steps: [BreathingPattern.Step] = [] }

    private let short = BreathingPattern(inhale: 2, hold: 1, exhale: 2, rounds: 2)
    private let settings = BreathingSettings(defaults: UserDefaults(suiteName: "breathing-\(UUID())")!)

    private func model(taps: Taps = Taps(), pattern: BreathingPattern? = nil) -> BreathingExerciseModel {
        BreathingExerciseModel(
            pattern: pattern ?? short, settings: settings, tick: {}, haptic: { taps.steps.append($0) })
    }

    @Test("counts every second to the end, tapping at each new step")
    func runs() async {
        let taps = Taps()
        let model = model(taps: taps)
        #expect(model.moment == BreathingPattern.Moment(round: 1, step: .inhale, secondsLeft: 2))
        await model.run()
        #expect(model.isFinished && model.elapsed == short.totalSeconds && model.moment == nil)
        #expect(taps.steps == [.inhale, .hold, .exhale, .inhale, .hold, .exhale])
    }

    @Test("Jeda stops the count until Lanjutkan")
    func pauses() async {
        let model = model()
        model.togglePause()
        let run = Task { await model.run() }
        for _ in 0..<50 { await Task.yield() }
        #expect(model.elapsed == 0 && model.isPaused)
        model.togglePause()
        await run.value
        #expect(model.isFinished)
    }

    @Test("taps nothing once turned off, and the next exercise starts off")
    func hapticsOff() async {
        let taps = Taps()
        let model = model(taps: taps)
        #expect(model.hapticsOn)
        model.toggleHaptics()
        #expect(!model.hapticsOn && !settings.hapticsOn)
        await model.run()
        #expect(taps.steps.isEmpty)
        #expect(!self.model().hapticsOn)
        model.toggleHaptics()
        #expect(model.hapticsOn && settings.hapticsOn)
    }

    @Test("stops when the screen goes and the wait is cancelled")
    func cancelled() async {
        struct Cancelled: Error {}
        let model = BreathingExerciseModel(settings: settings, tick: { throw Cancelled() }, haptic: { _ in })
        #expect(model.pattern == .calming)
        await model.run()
        #expect(model.elapsed == 0 && !model.isFinished)
    }

    @Test("the setting is on until the person turns it off")
    func settingDefault() {
        #expect(BreathingSettings(defaults: UserDefaults(suiteName: "breathing-\(UUID())")!).hapticsOn)
        let standard = UserDefaults.standard.object(forKey: "care.breathing.haptics") as? Bool ?? true
        #expect(BreathingSettings().hapticsOn == standard)
    }
}
