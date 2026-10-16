import Domain
import Foundation

/**
 What every Catat model reaches outside itself for, given once by the composition root: the API,
 Kira Peduli's crisis signal and check-in, the on-device readers, the camera and the microphone, the
 clock, the ids, and the two words the app's catalog supplies to data (the name of a draft or
 receipt that has none).
 */
package struct RecordDependencies: Sendable {
    /** The Catat endpoints. */
    package let service: any RecordService
    /** Kira Peduli's crisis signal and check-in (PED-02, PED-05, PED-06). */
    package let checkIns: any CheckInService
    /** The phrase list and the on-device model, which find a crisis signal before a message is read. */
    package let crisis: CrisisDetector
    /** The slang rules and the on-device model. */
    package let reader: MessageReader
    /** Vision, for receipts. */
    package let receiptReader: any ReceiptTextReading
    /** The camera of Scan Struk. */
    package let camera: any ReceiptCapturing
    /** Speech, for the voice panel. */
    package let transcriber: any VoiceTranscribing
    /** The time and the waiting. */
    package let clock: any RecordClock
    /** A new idempotency key. */
    package let makeId: @Sendable () -> String
    /** A receipt's name when its head has none ("Struk"). */
    package let receiptName: String
    /** A category's name, for a manual entry left without one ("Belanja"). */
    package let categoryName: @Sendable (TransactionCategory) -> String
    /** The on-device model's look at a receipt photo, on iOS 27 and later; nil before. */
    package let receiptAssistant: (any ReceiptAssisting)?

    /** Everything Catat needs; the clock and the ids default to the system's. */
    package init(
        service: any RecordService, checkIns: any CheckInService, crisis: CrisisDetector, reader: MessageReader, receiptReader: any ReceiptTextReading,
        camera: any ReceiptCapturing, transcriber: any VoiceTranscribing, clock: any RecordClock = SystemRecordClock(),
        makeId: @escaping @Sendable () -> String = { UUID().uuidString }, receiptName: String,
        categoryName: @escaping @Sendable (TransactionCategory) -> String,
        receiptAssistant: (any ReceiptAssisting)? = nil
    ) {
        self.service = service
        self.checkIns = checkIns
        self.crisis = crisis
        self.reader = reader
        self.receiptReader = receiptReader
        self.camera = camera
        self.transcriber = transcriber
        self.clock = clock
        self.makeId = makeId
        self.receiptName = receiptName
        self.categoryName = categoryName
        self.receiptAssistant = receiptAssistant
    }
}
