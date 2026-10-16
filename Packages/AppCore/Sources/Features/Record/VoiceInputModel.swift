import Foundation
import Observation

/**
 Input Suara (CAT-10): the panel that takes the composer's place while the person speaks. The
 transcript shows live, the duration counts up, and the waveform follows the voice. Berhenti sends
 the text as a voice message, which becomes drafts; Batalkan throws the recording away. The audio
 never leaves the device and is not kept; the plan's voice seconds cap the recording.
 */
@MainActor
@Observable
package final class VoiceInputModel {
    /** Where the recording is. */
    package enum State: Equatable, Sendable {
        /** Asking for access and starting the recogniser. */
        case starting
        /** Recording and transcribing. */
        case listening
        /** The microphone or speech recognition was not allowed. */
        case denied
        /** The device cannot transcribe Indonesian on the device. */
        case unavailable
    }

    /** The waveform's bars (InputSuara). */
    package static let barCount = 28

    /** Where the recording is. */
    package internal(set) var state = State.starting
    /** The live transcript. */
    package internal(set) var transcript = ""
    /** The seconds recorded so far. */
    package internal(set) var elapsedSeconds = 0
    /** The newest levels, oldest first, each from 0 to 1; silence before the first sound. */
    package internal(set) var levels: [Double] = Array(repeating: 0, count: barCount)
    private let transcriber: any VoiceTranscribing
    private let clock: any RecordClock
    private let limitSeconds: Int
    private let onFinish: (String, Int) -> Void
    private let onCancel: () -> Void
    private var isDone = false

    /** `limitSeconds` is what is left of the month's voice quota. */
    package init(
        transcriber: any VoiceTranscribing, clock: any RecordClock, limitSeconds: Int,
        onFinish: @escaping (String, Int) -> Void, onCancel: @escaping () -> Void
    ) {
        self.transcriber = transcriber
        self.clock = clock
        self.limitSeconds = limitSeconds
        self.onFinish = onFinish
        self.onCancel = onCancel
    }

    /** Asks for access, then listens until Berhenti, Batalkan, the end of the stream or the quota. */
    package func start() async {
        guard await transcriber.requestAccess() else {
            state = .denied
            return
        }
        let updates: AsyncThrowingStream<VoiceUpdate, any Error>
        do {
            updates = try await transcriber.start()
        } catch {
            state = .unavailable
            return
        }
        state = .listening
        let ticking = Task { await tick() }
        defer { ticking.cancel() }
        do {
            for try await update in updates where !isDone {
                transcript = update.transcript
                levels = Array((levels + [min(max(update.level, 0), 1)]).suffix(Self.barCount))
            }
        } catch {
            /** error ignored: the transcript so far is kept; Berhenti still sends it */
        }
    }

    /** Berhenti: sends what was heard; nothing heard is the same as Batalkan. */
    package func stop() async {
        guard !isDone else { return }
        isDone = true
        await transcriber.stop()
        let text = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            onCancel()
        } else {
            onFinish(text, max(1, elapsedSeconds))
        }
    }

    /** Batalkan rekaman, and Tutup on the denied or unavailable panel. */
    package func cancel() async {
        guard !isDone else { return }
        isDone = true
        await transcriber.stop()
        onCancel()
    }

    /** Counts the seconds, and stops at the end of the quota. */
    private func tick() async {
        while !isDone {
            do { try await clock.sleep(seconds: 1) } catch { return }
            guard !isDone else { return }
            elapsedSeconds += 1
            if elapsedSeconds >= limitSeconds { await stop() }
        }
    }
}
