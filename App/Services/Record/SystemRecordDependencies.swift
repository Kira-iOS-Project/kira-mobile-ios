/**
 Catat's dependencies on a real device: the API service the root gives, the slang rules with Apple's
 on-device model, Vision, the camera and Speech. Nothing here sends text, audio or images anywhere.
 */
import Domain
import Features
import Foundation

extension RecordDependencies {
    /**
     Catat on `service` and Kira Peduli's `checkIns`, with the device's own readers, camera and
     microphone; a crisis signal is found by the phrase list and Apple's on-device model.
     */
    static func system(service: any RecordService, checkIns: any CheckInService) -> RecordDependencies {
        RecordDependencies(
            service: service, checkIns: checkIns, crisis: CrisisDetector(refiner: FoundationModelsCrisisRefiner()),
            reader: MessageReader(
                fallbackName: String(localized: "record.draft.fallbackName"), refiner: FoundationModelsRefiner()),
            receiptReader: VisionReceiptReader(), camera: AVReceiptCamera(), transcriber: DeviceVoiceTranscriber(),
            receiptName: String(localized: "record.receipt.fallbackName"),
            categoryName: { String(localized: $0.title) }, receiptAssistant: FoundationModelsReceiptAssistant())
    }
}
