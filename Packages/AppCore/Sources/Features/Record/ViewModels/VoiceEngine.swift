/**
 Which on-device recogniser Input Suara uses for Indonesian (CAT-10). Apple's DictationTranscriber
 knows id-ID on iOS 26 and later while SpeechTranscriber does not, and SFSpeechRecognizer has no
 on-device Indonesian on most devices, so the order is dictation, transcriber, recogniser. Never a
 server: with none of them, voice is unavailable.
 */
package enum VoiceEngine: Equatable, Sendable {
    /** SpeechAnalyzer with DictationTranscriber (iOS 26 and later). */
    case dictation
    /** SpeechAnalyzer with SpeechTranscriber (iOS 26 and later). */
    case transcriber
    /** SFSpeechRecognizer with on-device recognition required. */
    case recognizer
}

/** What the device can recognise offline in Indonesian. */
package struct VoiceSupport: Equatable, Sendable {
    /** DictationTranscriber lists id-ID. */
    package let dictation: Bool
    /** SpeechTranscriber lists id-ID. */
    package let transcriber: Bool
    /** SFSpeechRecognizer recognises id-ID on the device. */
    package let onDeviceRecognizer: Bool

    /** What the device reported. */
    package init(dictation: Bool, transcriber: Bool, onDeviceRecognizer: Bool) {
        self.dictation = dictation
        self.transcriber = transcriber
        self.onDeviceRecognizer = onDeviceRecognizer
    }

    /** The first engine the device supports, or nil when none works offline. */
    package var engine: VoiceEngine? {
        if dictation { return .dictation }
        if transcriber { return .transcriber }
        return onDeviceRecognizer ? .recognizer : nil
    }
}
