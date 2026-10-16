import Testing

@testable import Features

@Suite("VoiceEngine")
struct VoiceEngineTests {
    @Test(
        "dictation first, then the transcriber, then the on-device recogniser, else none",
        arguments: [
            (VoiceSupport(dictation: true, transcriber: true, onDeviceRecognizer: true), VoiceEngine?.some(.dictation)),
            (VoiceSupport(dictation: false, transcriber: true, onDeviceRecognizer: true), .transcriber),
            (VoiceSupport(dictation: false, transcriber: false, onDeviceRecognizer: true), .recognizer),
            (VoiceSupport(dictation: false, transcriber: false, onDeviceRecognizer: false), nil),
        ])
    func engine(support: VoiceSupport, expected: VoiceEngine?) {
        #expect(support.engine == expected)
    }
}
