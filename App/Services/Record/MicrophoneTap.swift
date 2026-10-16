/**
 The microphone for Input Suara: the audio session set for recording, an engine tap that hands every
 buffer to the recogniser, and the input level about eight times a second for the waveform.
 */
import AVFoundation

nonisolated final class MicrophoneTap: @unchecked Sendable {
    private let engine = AVAudioEngine()
    /** Seconds between two levels. */
    private let levelInterval = 0.12

    /** The microphone's own format, for a converter. */
    var inputFormat: AVAudioFormat { engine.inputNode.outputFormat(forBus: 0) }

    /** Starts recording; `onBuffer` gets every buffer, `onLevel` the level from 0 to 1. */
    func start(onBuffer: @escaping @Sendable (AVAudioPCMBuffer) -> Void, onLevel: @escaping @Sendable (Double) -> Void)
        throws
    {
        let audio = AVAudioSession.sharedInstance()
        try audio.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audio.setActive(true, options: .notifyOthersOnDeactivation)
        let interval = levelInterval
        var last = Date.distantPast
        engine.inputNode.installTap(onBus: 0, bufferSize: 1_024, format: inputFormat) { buffer, _ in
            onBuffer(buffer)
            let now = Date()
            guard now.timeIntervalSince(last) >= interval else { return }
            last = now
            onLevel(Self.level(of: buffer))
        }
        engine.prepare()
        try engine.start()
    }

    func stop() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /** The buffer's loudness from 0 (−50 dB or quieter) to 1 (0 dB). */
    private static func level(of buffer: AVAudioPCMBuffer) -> Double {
        guard let samples = buffer.floatChannelData?[0], buffer.frameLength > 0 else { return 0 }
        let count = Int(buffer.frameLength)
        var sum: Float = 0
        for index in 0..<count { sum += samples[index] * samples[index] }
        let rms = (sum / Float(count)).squareRoot()
        let decibels = 20 * log10(max(rms, 0.000_01))
        return Double(min(max((decibels + 50) / 50, 0), 1))
    }
}

/** Converts microphone buffers to the format a recogniser asks for. */
nonisolated final class BufferConverter: @unchecked Sendable {
    private let converter: AVAudioConverter?
    private let format: AVAudioFormat

    init(from input: AVAudioFormat, to format: AVAudioFormat) {
        self.converter = AVAudioConverter(from: input, to: format)
        self.format = format
    }

    /** `buffer` in the target format, or nil when it cannot be converted. */
    func convert(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        guard let converter else { return nil }
        let ratio = format.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up))
        guard let output = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else { return nil }
        var isConsumed = false
        var failure: NSError?
        converter.convert(to: output, error: &failure) { _, status in
            if isConsumed {
                status.pointee = .noDataNow
                return nil
            }
            isConsumed = true
            status.pointee = .haveData
            return buffer
        }
        return failure == nil ? output : nil
    }
}
