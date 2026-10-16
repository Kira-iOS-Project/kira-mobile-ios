/**
 Input Suara's speech recognition, on the device only (CAT-10). `VoiceSupport` picks the engine:
 SpeechAnalyzer with DictationTranscriber (which knows id-ID on iOS 26 and later), else with
 SpeechTranscriber, else SFSpeechRecognizer where it recognises Indonesian on the device. Never a
 server. The audio goes from the microphone to the recogniser and nowhere else, and is not kept.
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
        let engine = await Self.support().engine
        switch engine {
        case .dictation?, .transcriber?:
            guard #available(iOS 26, *), let engine else { throw VoiceFailure.unavailable }
            next = AnalyzerVoiceSession(engine: engine)
        case .recognizer:
            next = RecognizerVoiceSession()
        case nil:
            throw VoiceFailure.unavailable
        }
        lock.withLock { session = next }
        return try await next.start()
    }

    /** What this device recognises offline in Indonesian. */
    static func support() async -> VoiceSupport {
        let locale = Locale(identifier: "id-ID")
        let recognizer = SFSpeechRecognizer(locale: locale)?.supportsOnDeviceRecognition ?? false
        guard #available(iOS 26, *) else {
            return VoiceSupport(dictation: false, transcriber: false, onDeviceRecognizer: recognizer)
        }
        return VoiceSupport(
            dictation: await DictationTranscriber.supportedLocale(equivalentTo: locale) != nil,
            transcriber: await SpeechTranscriber.supportedLocale(equivalentTo: locale) != nil,
            onDeviceRecognizer: recognizer)
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
