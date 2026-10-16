/**
 Input Suara's speech recognition, on the device only (CAT-10): SpeechAnalyzer on iOS 26 and later
 when it has Indonesian, else SFSpeechRecognizer with on-device recognition required. The audio
 goes from the microphone to the recogniser and nowhere else, and is not kept.
 */
import AVFoundation
import Domain
import Features
import Foundation
import Speech

nonisolated final class DeviceVoiceTranscriber: VoiceTranscribing, @unchecked Sendable {
    private let lock = NSLock()
    private var session: (any VoiceSession)?

    func requestAccess() async -> Bool {
        guard await AVAudioApplication.requestRecordPermission() else { return false }
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
        return status == .authorized
    }

    func start() async throws -> AsyncThrowingStream<VoiceUpdate, any Error> {
        let next: any VoiceSession
        if #available(iOS 26, *), await AnalyzerVoiceSession.supportsIndonesian() {
            next = AnalyzerVoiceSession()
        } else {
            next = RecognizerVoiceSession()
        }
        lock.withLock { session = next }
        return try await next.start()
    }

    func stop() async {
        let current = lock.withLock {
            defer { session = nil }
            return session
        }
        await current?.stop()
    }
}

/** One recording with one recogniser. */
protocol VoiceSession: Sendable {
    func start() async throws -> AsyncThrowingStream<VoiceUpdate, any Error>
    func stop() async
}

/** Why the device cannot transcribe. */
enum VoiceFailure: Error {
    case unavailable
}

/** The transcript so far and the latest level, shared by the audio thread and the recogniser. */
nonisolated final class TranscriptState: @unchecked Sendable {
    private let lock = NSLock()
    private var finalized = ""
    private var volatile = ""
    private var latestLevel = 0.0

    /** The settled text and the text still being heard. */
    var transcript: String { lock.withLock { finalized + volatile } }

    var level: Double {
        get { lock.withLock { latestLevel } }
        set { lock.withLock { latestLevel = newValue } }
    }

    /** Text the recogniser may still change. */
    func hear(_ text: String) {
        lock.withLock { volatile = text }
    }

    /** Text the recogniser settled on. */
    func settle(_ text: String) {
        lock.withLock {
            finalized += text
            volatile = ""
        }
    }

    /** The whole transcript so far, replacing it (SFSpeechRecognizer resends everything). */
    func replace(_ text: String) {
        lock.withLock {
            finalized = text
            volatile = ""
        }
    }

    var update: VoiceUpdate { VoiceUpdate(transcript: transcript, level: level) }
}

/** A value an Apple framework uses across threads in a way it documents as safe. */
nonisolated struct UncheckedSendable<Value>: @unchecked Sendable {
    let value: Value

    init(_ value: Value) {
        self.value = value
    }
}
