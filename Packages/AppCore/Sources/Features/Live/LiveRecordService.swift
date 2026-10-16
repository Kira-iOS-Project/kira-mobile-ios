import APIClient
import Domain

/** Catat's calls over the API client (CAT-01 to CAT-06, CAT-10). */
package struct LiveRecordService: RecordService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /me`. */
    package func profile() async throws -> RecordProfile {
        try RecordProfile(try await api.getMe())
    }

    /** `GET /chat/messages?before=`. */
    package func messages(before cursor: String?) async throws -> ChatPage {
        let page = try await api.listChatMessages(before: cursor)
        return ChatPage(items: try page.items.map(ChatMessage.init), nextCursor: page.nextCursor)
    }

    /** `POST /chat/messages`. */
    package func send(_ message: OutgoingMessage) async throws -> SendResult {
        try SendResult(try await api.sendChatMessage(try ChatMessageInputDTO(message)))
    }

    /** `PUT /chat/messages/{id}/drafts`. */
    package func updateDrafts(messageId: String, drafts: [DraftItem]) async throws -> ChatMessage {
        try ChatMessage(try await api.updateChatDrafts(messageId: messageId, drafts: drafts.map(DraftItemDTO.init)))
    }

    /** `POST /chat/messages/{id}/commit`. */
    package func commit(messageId: String) async throws -> CommitResult {
        let committed = try await api.commitChatDrafts(messageId: messageId)
        return CommitResult(
            message: try ChatMessage(committed.message), remaining: try ChatMessage(committed.remaining))
    }

    /** `DELETE /transactions/batches/{batchId}`. */
    package func undo(batchId: String) async throws -> ChatMessage {
        try ChatMessage(try await api.undoTransactionBatch(batchId: batchId))
    }

    /** `POST /chat/receipts`. */
    package func sendReceipt(_ receipt: ReceiptInput) async throws -> SendResult {
        let items = receipt.items.map { ReceiptItemDTO(name: $0.name, amount: $0.amount, category: $0.category) }
        let sent = try await api.sendReceipt(
            clientId: receipt.clientId, storeName: receipt.storeName, occurredAt: receipt.occurredAt,
            total: receipt.total, items: items)
        return try SendResult(sent)
    }

    /** `POST /transactions`. */
    package func saveManual(_ transaction: ManualTransactionInput) async throws -> ManualSaveResult {
        let saved = try await api.createTransaction(
            ManualTransactionInputDTO(
                clientId: transaction.clientId, type: transaction.type, amount: transaction.amount,
                category: transaction.category, name: transaction.name, occurredAt: transaction.occurredAt,
                note: transaction.note))
        return ManualSaveResult(transactionId: saved.transaction.id, message: try ChatMessage(saved.message))
    }
}
