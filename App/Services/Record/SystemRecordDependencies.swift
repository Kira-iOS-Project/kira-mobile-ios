/**
 Catat's dependencies on a real device: the API service the root gives, the slang rules with Apple's
 on-device model, Vision, the camera and Speech. Nothing here sends text, audio or images anywhere.
 */
import Domain
import Features
import Foundation

extension RecordDependencies {
    /** Catat on `service` with the device's own readers, camera and microphone. */
    static func system(service: any RecordService) -> RecordDependencies {
        RecordDependencies(
            service: service,
            reader: MessageReader(
                fallbackName: String(localized: "record.draft.fallbackName"), refiner: FoundationModelsRefiner()),
            receiptReader: VisionReceiptReader(), camera: AVReceiptCamera(), transcriber: DeviceVoiceTranscriber(),
            receiptName: String(localized: "record.receipt.fallbackName"),
            categoryName: { String(localized: $0.title) }, receiptAssistant: FoundationModelsReceiptAssistant())
    }
}
