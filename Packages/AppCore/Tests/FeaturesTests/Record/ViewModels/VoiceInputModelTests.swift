import Foundation
import Testing

@testable import Features

@MainActor
@Suite("VoiceInputModel")
struct VoiceInputModelTests {
    private struct Outcome {
        var finished: (text: String, seconds: Int)?
        var cancelled = false
    }

    private final class Recorder {
        var outcome = Outcome()
    }

    private func model(_ transcriber: FakeTranscriber, clock: ManualClock, limit: Int = 600, recorder: Recorder)
        -> VoiceInputModel
    {
        VoiceInputModel(
            transcriber: transcriber, clock: clock, limitSeconds: limit,
            onFinish: { recorder.outcome.finished = ($0, $1) }, onCancel: { recorder.outcome.cancelled = true })
    }

    @Test("listening shows the live transcript, the levels and the seconds; Berhenti sends the text")
    func listen() async throws {
        let transcriber = FakeTranscriber()
        let clock = ManualClock()
        let recorder = Recorder()
        let voice = model(transcriber, clock: clock, recorder: recorder)
        #expect(voice.state == .starting)
        let listening = Task { await voice.start() }
        await settle()
        #expect(voice.state == .listening)
        let continuation = try #require(transcriber.continuation)
        continuation.yield(VoiceUpdate(transcript: "tadi parkir lima ribu", level: 1.4))
        continuation.yield(VoiceUpdate(transcript: "tadi parkir lima ribu, terus bakso", level: 0.3))
        await settle()
        #expect(voice.transcript == "tadi parkir lima ribu, terus bakso")
        #expect(voice.levels.count == VoiceInputModel.barCount)
        #expect(Array(voice.levels.suffix(2)) == [1, 0.3])
        clock.wake()
        await settle()
        #expect(voice.elapsedSeconds == 1)
        await voice.stop()
        await voice.stop()
        await listening.value
        #expect(recorder.outcome.finished?.text == "tadi parkir lima ribu, terus bakso")
        #expect(recorder.outcome.finished?.seconds == 1)
        #expect(transcriber.stopCount == 1)
    }

    @Test("the quota's end stops the recording; nothing heard is a cancel")
    func limit() async throws {
        let transcriber = FakeTranscriber()
        let clock = ManualClock()
        let recorder = Recorder()
        let voice = model(transcriber, clock: clock, limit: 1, recorder: recorder)
        let listening = Task { await voice.start() }
        await settle()
        clock.wake()
        await settle()
        await listening.value
        #expect(recorder.outcome.cancelled)
        #expect(recorder.outcome.finished == nil)
    }

    @Test("Batalkan throws the recording away; a failed stream keeps the transcript; a failed clock stops counting")
    func cancel() async throws {
        let transcriber = FakeTranscriber()
        let clock = ManualClock()
        let recorder = Recorder()
        let voice = model(transcriber, clock: clock, recorder: recorder)
        let listening = Task { await voice.start() }
        await settle()
        let continuation = try #require(transcriber.continuation)
        continuation.yield(VoiceUpdate(transcript: "kopi", level: -1))
        await settle()
        #expect(voice.levels.last == 0)
        clock.wake(throwing: CancellationError())
        continuation.finish(throwing: OfflineError())
        await listening.value
        #expect(voice.transcript == "kopi")
        await voice.cancel()
        await voice.cancel()
        #expect(recorder.outcome.cancelled)
        #expect(recorder.outcome.finished == nil)
        #expect(transcriber.stopCount == 1)
    }

    @Test("access denied, or no recogniser on the device")
    func unavailable() async {
        let denied = FakeTranscriber()
        denied.allowsAccess = false
        let recorder = Recorder()
        let first = model(denied, clock: ManualClock(), recorder: recorder)
        await first.start()
        #expect(first.state == .denied)
        let broken = FakeTranscriber()
        broken.startError = OfflineError()
        let second = model(broken, clock: ManualClock(), recorder: recorder)
        await second.start()
        #expect(second.state == .unavailable)
    }
}
