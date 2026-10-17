/**
 The Catat board's chat (canvas Catat): "bensin 30rb" saved at 08.12, then "makan siang 25rb, grab
 ke kantor 18rb, kopi goceng" at 12.41 with its three drafts waiting; and the devices of a preview,
 which read the board's receipt and hear the board's voice note.
 */
import Domain
import Features
import Foundation

nonisolated enum PreviewRecordData {
    static let board: [ChatMessage] = {
        let morning = PreviewRecordService.morning
        let noon = PreviewRecordService.noon
        let fuel = DraftItem(
            id: "d0", type: .expense, name: "Bensin", amount: 30_000, category: .transport, occurredAt: morning)
        let drafts = [
            DraftItem(id: "d1", type: .expense, name: "Makan Siang", amount: 25_000, category: .food, occurredAt: noon),
            DraftItem(
                id: "d2", type: .expense, name: "Grab ke Kantor", amount: 18_000, category: .transport, occurredAt: noon
            ),
            DraftItem(id: "d3", type: .expense, name: "Kopi", amount: 5_000, category: .coffee, occurredAt: noon),
        ]
        return [
            ChatMessage(id: "m1", sender: .person, kind: .personText, body: "bensin 30rb", createdAt: morning),
            ChatMessage(
                id: "k1", sender: .kira, kind: .drafts, createdAt: morning, replyToId: "m1", drafts: [fuel],
                draftStatus: .committed, batchId: "batch-k1"),
            ChatMessage(
                id: "m2", sender: .person, kind: .personText,
                body: "makan siang 25rb, grab ke kantor 18rb, kopi goceng",
                createdAt: noon),
            ChatMessage(
                id: "k2", sender: .kira, kind: .drafts, createdAt: noon, replyToId: "m2", drafts: drafts,
                draftStatus: .pending),
        ]
    }()

    /** The board's receipt as Vision would read it (ScanStruk). */
    static let receiptLines = [
        "TOKO SEJAHTERA", "Jl. Melati No. 12, Jakarta", "15-10-2026 12:58", "Beras 5 Kg 72.000,00",
        "Minyak Goreng 2 L 38.000,00", "Sabun Cuci 15.500,00", "TOTAL 125.500,00", "TUNAI 150.000,00",
        "KEMBALI 24.500,00",
    ]

    /** Catat with the preview service and devices. */
    static var dependencies: RecordDependencies {
        RecordDependencies(
            service: PreviewRecordService(), checkIns: PreviewCheckInService(), crisis: CrisisDetector(refiner: nil),
            reader: MessageReader(fallbackName: String(localized: "record.draft.fallbackName"), refiner: nil),
            receiptReader: PreviewReceiptReader(), camera: PreviewCamera(), transcriber: PreviewTranscriber(),
            receiptName: String(localized: "record.receipt.fallbackName"),
            categoryName: { String(localized: $0.title) })
    }
}

/** Reads the board's receipt from any image. */
nonisolated struct PreviewReceiptReader: ReceiptTextReading {
    func lines(in _: Data) -> [String] { PreviewRecordData.receiptLines }
}

/** A camera that takes an empty photo. */
nonisolated struct PreviewCamera: ReceiptCapturing {
    func start() {}
    func stop() {}
    func capture() -> Data { Data() }
    func setTorch(_: Bool) {}
}

/** Hears the board's voice note (InputSuara), word by word. */
nonisolated struct PreviewTranscriber: VoiceTranscribing {
    private static let words = "tadi parkir lima ribu, terus makan bakso dua puluh ribu".split(separator: " ")

    func requestAccess() -> Bool { true }

    func start() -> AsyncThrowingStream<VoiceUpdate, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                for count in 1...Self.words.count {
                    try? await Task.sleep(for: .milliseconds(350))
                    let text = Self.words.prefix(count).joined(separator: " ")
                    continuation.yield(VoiceUpdate(transcript: text, level: Double(count % 5 + 2) / 7))
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func stop() {}
}
