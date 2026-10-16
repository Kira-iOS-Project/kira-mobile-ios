/**
 SFSpeechRecognizer in Indonesian with on-device recognition required, for iOS 17 to 25 and devices
 whose SpeechAnalyzer lacks Indonesian. A device that cannot recognise Indonesian offline refuses,
 rather than sending audio to a server.
 */
import Domain
import Features
import Foundation
import Speech

nonisolated final class RecognizerVoiceSession: VoiceSession, @unchecked Sendable {
    private let microphone = MicrophoneTap()
    private let state = TranscriptState()
    private let lock = NSLock()
    private var task: SFSpeechRecognitionTask?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var continuation: AsyncThrowingStream<VoiceUpdate, any Error>.Continuation?

    func start() throws -> AsyncThrowingStream<VoiceUpdate, any Error> {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "id-ID")), recognizer.isAvailable,
            recognizer.supportsOnDeviceRecognition
        else { throw VoiceFailure.unavailable }
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = true
        request.addsPunctuation = true
        let (stream, continuation) = AsyncThrowingStream.makeStream(of: VoiceUpdate.self, throwing: (any Error).self)
        let state = state
        /** Apple documents `append` as safe from the audio thread, which is where the tap calls it. */
        let appending = UncheckedSendable(request)
        try microphone.start(
            onBuffer: { appending.value.append($0) },
            onLevel: { level in
                state.level = level
                continuation.yield(state.update)
            })
        let task = recognizer.recognitionTask(with: request) { result, error in
            if let result {
                state.replace(result.bestTranscription.formattedString)
                continuation.yield(state.update)
            }
            if error != nil || result?.isFinal == true { continuation.finish() }
        }
        lock.withLock {
            self.task = task
            self.request = request
            self.continuation = continuation
        }
        return stream
    }

    func stop() {
        microphone.stop()
        let (task, request, continuation) = lock.withLock { (self.task, self.request, self.continuation) }
        request?.endAudio()
        task?.finish()
        continuation?.finish()
    }
}
