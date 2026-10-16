/**
 Catat before the API is wired: the boards' sample data (Dinda on Kira Gratis, 15 October 2026) kept
 in memory, answering every call the way the contract says the API will.
 */
import Domain
import Features
import Foundation

nonisolated final class PreviewRecordService: RecordService, @unchecked Sendable {
    /** 15 October 2026, 08.12 and 12.41 WIB. */
    static let morning = Date(timeIntervalSince1970: 1_792_026_720)
    static let noon = Date(timeIntervalSince1970: 1_792_042_860)
    private let lock = NSLock()
    private var counter = 0
    private var usage = Usage(
        aiMessages: UsageMeter(used: 12, limit: 30), receipts: UsageMeter(used: 4, limit: 10),
        voiceSeconds: UsageMeter(used: 0, limit: 0), resetsOn: CalendarDay(Date(timeIntervalSince1970: 1_793_466_000)))
    private var items: [ChatMessage] = PreviewRecordData.board

    func profile() -> RecordProfile {
        RecordProfile(
            displayName: "Dinda", plan: .free, usage: usage, periodStart: Date(timeIntervalSince1970: 1_790_269_200),
            periodEnd: Date(timeIntervalSince1970: 1_792_774_800), aiEnabled: true, lastExpenseCategory: .shopping,
            lastIncomeCategory: .salary)
    }

    func messages(before cursor: String?) -> ChatPage {
        ChatPage(items: cursor == nil ? lock.withLock { items } : [], nextCursor: nil)
    }

    func send(_ message: OutgoingMessage) -> SendResult {
        let person = ChatMessage(
            id: nextId(), sender: .person, kind: .personText, body: message.text, createdAt: stamp())
        let drafts = message.drafts.map { draft in
            DraftItem(
                id: nextId(), type: draft.type, name: draft.name, amount: draft.amount, category: draft.category,
                occurredAt: draft.occurredAt, spanStart: draft.spanStart, spanEnd: draft.spanEnd)
        }
        let reply = ChatMessage(
            id: nextId(), sender: .kira, kind: drafts.isEmpty ? .noDrafts : .drafts, createdAt: stamp(),
            replyToId: person.id, drafts: drafts, draftStatus: drafts.isEmpty ? nil : .pending)
        return store([person, reply])
    }

    func updateDrafts(messageId: String, drafts: [DraftItem]) -> ChatMessage {
        update(messageId) { message in
            message.drafts = drafts
            message.draftStatus = drafts.isEmpty ? .discarded : .pending
        }
    }

    func commit(messageId: String) -> CommitResult {
        let message = update(messageId) { message in
            message.draftStatus = .committed
            message.batchId = "batch-\(messageId)"
        }
        let remaining = ChatMessage(
            id: nextId(), sender: .kira, kind: .remaining, createdAt: stamp(), replyToId: messageId,
            remaining: 1_792_000,
            perDay: 179_200)
        return CommitResult(message: message, remaining: remaining)
    }

    func undo(batchId: String) -> ChatMessage {
        update(String(batchId.dropFirst("batch-".count))) { message in
            message.draftStatus = .pending
            message.batchId = nil
        }
    }

    func sendReceipt(_ receipt: ReceiptInput) -> SendResult {
        let person = ChatMessage(
            id: nextId(), sender: .person, kind: .personReceipt, body: receipt.storeName, createdAt: stamp())
        let drafts = receipt.items.map { item in
            DraftItem(
                id: nextId(), type: .expense, name: item.name, amount: item.amount, category: item.category,
                occurredAt: receipt.occurredAt)
        }
        let reply = ChatMessage(
            id: nextId(), sender: .kira, kind: .drafts, createdAt: stamp(), replyToId: person.id, drafts: drafts,
            draftStatus: .pending)
        return store([person, reply])
    }

    func saveManual(_ transaction: ManualTransactionInput) -> ManualSaveResult {
        let draft = DraftItem(
            id: transaction.clientId, type: transaction.type, name: transaction.name, amount: transaction.amount,
            category: transaction.category, occurredAt: transaction.occurredAt)
        let message = ChatMessage(
            id: nextId(), sender: .kira, kind: .manualSaved, createdAt: stamp(), drafts: [draft],
            draftStatus: .committed)
        return ManualSaveResult(message: message)
    }

    /** The board's 12.41, a minute later for each message added. */
    private func stamp() -> Date {
        Self.noon.addingTimeInterval(Double(lock.withLock { counter }) * 60)
    }

    private func nextId() -> String {
        lock.withLock {
            counter += 1
            return "preview-\(counter)"
        }
    }

    private func store(_ messages: [ChatMessage]) -> SendResult {
        lock.withLock { items += messages }
        return SendResult(
            person: messages[0], reply: messages.count > 1 ? messages[1] : nil, quotaExhausted: false, usage: usage)
    }

    private func update(_ id: String, _ change: (inout ChatMessage) -> Void) -> ChatMessage {
        lock.withLock {
            guard let index = items.firstIndex(where: { $0.id == id }) else {
                /** `counter` read here, not through `stamp()`, which would take the held lock again. */
                let createdAt = Self.noon.addingTimeInterval(Double(counter) * 60)
                return ChatMessage(id: id, sender: .kira, kind: .noDrafts, createdAt: createdAt)
            }
            change(&items[index])
            return items[index]
        }
    }
}
