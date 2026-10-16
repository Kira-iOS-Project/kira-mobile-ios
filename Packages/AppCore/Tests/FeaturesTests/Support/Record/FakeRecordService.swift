import APIClient
import Domain
import Foundation

@testable import Features

/** A request that got no answer: the transport reports no connection. */
func offlineError() -> URLError { URLError(.notConnectedToInternet) }

/**
 A `RecordService` whose answers each test sets, and which records what it was asked. Each test
 makes its own, so no state is shared; the models call it from the main actor.
 */
final class FakeRecordService: RecordService, @unchecked Sendable {
    var profileResult: Result<RecordProfile, any Error> = .success(Fixtures.profile())
    var pages: [String?: Result<ChatPage, any Error>] = [nil: .success(ChatPage(items: [], nextCursor: nil))]
    var sendResult: Result<SendResult, any Error> = .failure(offlineError())
    var updateResult: Result<ChatMessage, any Error> = .failure(offlineError())
    var commitResult: Result<CommitResult, any Error> = .failure(offlineError())
    var undoResult: Result<ChatMessage, any Error> = .failure(offlineError())
    var receiptResult: Result<SendResult, any Error> = .failure(offlineError())
    var manualResult: Result<ManualSaveResult, any Error> = .failure(offlineError())

    private(set) var sent: [OutgoingMessage] = []
    private(set) var updates: [(messageId: String, drafts: [DraftItem])] = []
    private(set) var commits: [String] = []
    private(set) var undos: [String] = []
    private(set) var receipts: [ReceiptInput] = []
    private(set) var manuals: [ManualTransactionInput] = []

    func profile() throws -> RecordProfile { try profileResult.get() }

    func messages(before cursor: String?) throws -> ChatPage {
        try (pages[cursor] ?? .failure(offlineError())).get()
    }

    func send(_ message: OutgoingMessage) throws -> SendResult {
        sent.append(message)
        return try sendResult.get()
    }

    func updateDrafts(messageId: String, drafts: [DraftItem]) throws -> ChatMessage {
        updates.append((messageId, drafts))
        return try updateResult.get()
    }

    func commit(messageId: String) throws -> CommitResult {
        commits.append(messageId)
        return try commitResult.get()
    }

    func undo(batchId: String) throws -> ChatMessage {
        undos.append(batchId)
        return try undoResult.get()
    }

    func sendReceipt(_ receipt: ReceiptInput) throws -> SendResult {
        receipts.append(receipt)
        return try receiptResult.get()
    }

    func saveManual(_ transaction: ManualTransactionInput) throws -> ManualSaveResult {
        manuals.append(transaction)
        return try manualResult.get()
    }
}
