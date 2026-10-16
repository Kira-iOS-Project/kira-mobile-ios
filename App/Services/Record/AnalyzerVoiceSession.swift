/**
 SpeechAnalyzer with the Indonesian SpeechTranscriber, on iOS 26 and later: the model is installed
 on the device once (AssetInventory), the microphone's buffers are converted to its format, and its
 volatile results show while the person speaks, settling as they finalise.
 */
import AVFoundation
import Domain
import Features
import Foundation
import Speech

@available(iOS 26, *)
nonisolated final class AnalyzerVoiceSession: VoiceSession, @unchecked Sendable {
    private static let locale = Locale(identifier: "id-ID")
    private let microphone = MicrophoneTap()
    private let state = TranscriptState()
    private let lock = NSLock()
    private var analyzer: SpeechAnalyzer?
    private var inputs: AsyncStream<AnalyzerInput>.Continuation?

    /** Whether this device's SpeechTranscriber knows Indonesian. */
    static func supportsIndonesian() async -> Bool {
        await SpeechTranscriber.supportedLocales.contains { $0.identifier(.bcp47) == locale.identifier(.bcp47) }
    }

    func start() async throws -> AsyncThrowingStream<VoiceUpdate, any Error> {
        let transcriber = SpeechTranscriber(
            locale: Self.locale, transcriptionOptions: [], reportingOptions: [.volatileResults], attributeOptions: [])
        if let install = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            try await install.downloadAndInstall()
        }
        guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber]) else {
            throw VoiceFailure.unavailable
        }
        let analyzer = SpeechAnalyzer(modules: [transcriber])
        let (inputStream, inputs) = AsyncStream.makeStream(of: AnalyzerInput.self)
        try await analyzer.start(inputSequence: inputStream)
        let (stream, continuation) = AsyncThrowingStream.makeStream(of: VoiceUpdate.self, throwing: (any Error).self)
        let state = state
        Task {
            do {
                for try await result in transcriber.results {
                    let text = String(result.text.characters)
                    if result.isFinal { state.settle(text) } else { state.hear(text) }
                    continuation.yield(state.update)
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        let converter = BufferConverter(from: microphone.inputFormat, to: format)
        try microphone.start(
            onBuffer: { buffer in
                if let converted = converter.convert(buffer) { inputs.yield(AnalyzerInput(buffer: converted)) }
            },
            onLevel: { level in
                state.level = level
                continuation.yield(state.update)
            })
        lock.withLock {
            self.analyzer = analyzer
            self.inputs = inputs
        }
        return stream
    }

    func stop() async {
        microphone.stop()
        let (analyzer, inputs) = lock.withLock { (self.analyzer, self.inputs) }
        inputs?.finish()
        try? await analyzer?.finalizeAndFinishThroughEndOfInput()
    }
}
