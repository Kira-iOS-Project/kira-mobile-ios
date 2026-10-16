import Domain
import Foundation

@testable import Features

/** The board's sample data: Dinda on Kira Gratis, 15 October 2026 in Jakarta. */
enum Fixtures {
    /** 15 October 2026, 12.41 WIB. */
    static let noon = Date(timeIntervalSince1970: 1_792_042_860)

    static func usage(messages: Int = 12, receipts: Int = 4, voice: (used: Int, limit: Int) = (0, 0)) -> Usage {
        Usage(
            aiMessages: UsageMeter(used: messages, limit: 30), receipts: UsageMeter(used: receipts, limit: 10),
            voiceSeconds: UsageMeter(used: voice.used, limit: voice.limit),
            resetsOn: CalendarDay(noon.addingTimeInterval(17 * 86_400)))
    }

    static func profile(
        aiEnabled: Bool = true, usage: Usage = usage(), lastExpense: TransactionCategory? = .shopping,
        lastIncome: TransactionCategory? = nil
    ) -> RecordProfile {
        RecordProfile(
            displayName: "dinda", plan: .free, usage: usage, periodStart: noon.addingTimeInterval(-20 * 86_400),
            periodEnd: noon.addingTimeInterval(9 * 86_400), aiEnabled: aiEnabled, lastExpenseCategory: lastExpense,
            lastIncomeCategory: lastIncome)
    }

    static func draft(_ id: String, name: String, amount: Int, category: TransactionCategory = .food) -> DraftItem {
        DraftItem(
            id: id, type: category.type, name: name, amount: amount, category: category, occurredAt: noon, spanStart: 0,
            spanEnd: 4)
    }

    static func person(_ id: String, _ text: String, at date: Date = noon, kind: ChatMessageKind = .personText)
        -> ChatMessage
    {
        ChatMessage(id: id, sender: .person, kind: kind, body: text, createdAt: date, inputMethod: .keyboard)
    }

    static func drafts(
        _ id: String, replyTo: String?, items: [DraftItem], status: DraftStatus = .pending, batchId: String? = nil,
        at date: Date = noon
    ) -> ChatMessage {
        ChatMessage(
            id: id, sender: .kira, kind: .drafts, createdAt: date, replyToId: replyTo, drafts: items,
            draftStatus: status,
            parser: .slangRules, batchId: batchId, transactionIds: batchId.map { _ in items.map(\.id) },
            committedAt: status == .committed ? date : nil, itemCount: items.count)
    }

    static func kira(_ id: String, kind: ChatMessageKind, at date: Date = noon) -> ChatMessage {
        ChatMessage(id: id, sender: .kira, kind: kind, createdAt: date, remaining: 1_792_000, perDay: 179_200)
    }

    static func dependencies(
        service: FakeRecordService, clock: ManualClock = ManualClock(), refiner: (any DraftRefining)? = nil,
        receiptReader: FakeReceiptReader = FakeReceiptReader(), camera: FakeCamera = FakeCamera(),
        transcriber: FakeTranscriber = FakeTranscriber(), assistant: FakeReceiptAssistant? = nil
    ) -> RecordDependencies {
        let ids = IdSequence()
        return RecordDependencies(
            service: service, reader: MessageReader(fallbackName: "Transaksi", refiner: refiner),
            receiptReader: receiptReader, camera: camera, transcriber: transcriber, clock: clock,
            makeId: { ids.next() }, receiptName: "Struk", categoryName: { $0.rawValue }, receiptAssistant: assistant)
    }
}

/** Ids "id-1", "id-2", … in order. */
final class IdSequence: @unchecked Sendable {
    private var count = 0

    func next() -> String {
        count += 1
        return "id-\(count)"
    }
}
