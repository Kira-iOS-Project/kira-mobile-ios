import Domain

/**
 The Catat endpoints (CONTRACT "Catat" and the `GET /me` fields Catat reads). The integrator
 implements it with the generated client; previews and tests use their own. Every call throws an
 `AppProblem` for an answer the API refused, and any other error when the request did not arrive.
 */
package protocol RecordService: Sendable {
    /** `GET /me`: the initial, the period, the plan, the quotas, the AI consent, the last categories. */
    func profile() async throws -> RecordProfile
    /** `GET /chat/messages?before=`: the page before `cursor`, or the newest page for nil. */
    func messages(before cursor: String?) async throws -> ChatPage
    /** `POST /chat/messages`. */
    func send(_ message: OutgoingMessage) async throws -> SendResult
    /** `PUT /chat/messages/{id}/drafts`: the whole list; empty discards the drafts. */
    func updateDrafts(messageId: String, drafts: [DraftItem]) async throws -> ChatMessage
    /** `POST /chat/messages/{id}/commit`. */
    func commit(messageId: String) async throws -> CommitResult
    /** `DELETE /transactions/batches/{batchId}`: Urungkan, the drafts back to pending. */
    func undo(batchId: String) async throws -> ChatMessage
    /** `POST /chat/receipts`. */
    func sendReceipt(_ receipt: ReceiptInput) async throws -> SendResult
    /** `POST /transactions`, idempotent on the input's `clientId`. */
    func saveManual(_ transaction: ManualTransactionInput) async throws -> ManualSaveResult
}
