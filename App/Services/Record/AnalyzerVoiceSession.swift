/**
 SpeechAnalyzer in Indonesian on iOS 26 and later, with DictationTranscriber (which has id-ID) or
 SpeechTranscriber where it has the locale. The language model is installed on the device once
 (AssetInventory, while the panel says "Menyiapkan bahasa…"), the microphone's buffers are converted
 to its format, and volatile results show while the person speaks, settling as they finalise.
 */
import AVFoundation
import Features
import Foundation
import Speech

@available(iOS 26, *)
nonisolated final class AnalyzerVoiceSession: VoiceSession, @unchecked Sendable {
    private static let indonesian = Locale(identifier: "id-ID")
    private let engine: VoiceEngine
    private let microphone = MicrophoneTap()
    private let state = TranscriptState()
    private let lock = NSLock()
    private var analyzer: SpeechAnalyzer?
    private var inputs: AsyncStream<AnalyzerInput>.Continuation?

    /** A session with `engine`, `.dictation` or `.transcriber`. */
    init(engine: VoiceEngine) {
        self.engine = engine
    }

    func start() async throws -> AsyncThrowingStream<VoiceUpdate, any Error> {
        let (module, texts) = try await Self.module(for: engine)
        if let install = try await AssetInventory.assetInstallationRequest(supporting: [module]) {
            try await install.downloadAndInstall()
        }
        guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [module]) else {
            throw VoiceFailure.unavailable
        }
        let analyzer = SpeechAnalyzer(modules: [module])
        let (inputStream, inputs) = AsyncStream.makeStream(of: AnalyzerInput.self)
        try await analyzer.start(inputSequence: inputStream)
        let (stream, continuation) = AsyncThrowingStream.makeStream(of: VoiceUpdate.self, throwing: (any Error).self)
        let state = state
        Task {
            do {
                for try await (text, isFinal) in texts {
                    if isFinal { state.settle(text) } else { state.hear(text) }
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

    /** The module for `engine` in the locale it calls Indonesian, and its results as text. */
    private static func module(for engine: VoiceEngine) async throws -> (
        any SpeechModule, AsyncThrowingStream<(String, Bool), any Error>
    ) {
        switch engine {
        case .dictation:
            guard let locale = await DictationTranscriber.supportedLocale(equivalentTo: indonesian) else { break }
            let module = DictationTranscriber(locale: locale, preset: .progressiveLongDictation)
            return (module, texts(module.results) { (String($0.text.characters), $0.isFinal) })
        case .transcriber:
            guard let locale = await SpeechTranscriber.supportedLocale(equivalentTo: indonesian) else { break }
            let module = SpeechTranscriber(
                locale: locale, transcriptionOptions: [], reportingOptions: [.volatileResults], attributeOptions: [])
            return (module, texts(module.results) { (String($0.text.characters), $0.isFinal) })
        case .recognizer:
            break
        }
        throw VoiceFailure.unavailable
    }

    /** A module's results as text and whether each is final. */
    private static func texts<Results: AsyncSequence & Sendable>(
        _ results: Results, _ read: @escaping @Sendable (Results.Element) -> (String, Bool)
    ) -> AsyncThrowingStream<(String, Bool), any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await result in results { continuation.yield(read(result)) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
