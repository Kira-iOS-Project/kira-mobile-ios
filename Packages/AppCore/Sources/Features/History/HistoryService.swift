/**
 The calls behind Riwayat, Detail Transaksi, Riwayat Percakapan and Impor Mutasi (CAT-07 to CAT-12),
 in Domain values (CONTRACT.md, Catat). The integrator implements it with the generated client;
 every call throws an `AppProblem` when the API refuses it.
 */
import Domain

/** The history and import calls. */
package protocol HistoryService: Sendable {
    /** The current payday period: `GET /me`'s `period`. */
    func currentPeriod() async throws -> PayPeriod
    /** `GET /transactions`: a page of transactions, newest first. */
    func transactions(_ query: TransactionQuery) async throws -> TransactionPage
    /** `GET /transactions/summary`: the engine's totals of a range and of each day. */
    func summary(from start: CalendarDay, to end: CalendarDay) async throws -> TransactionSummary
    /** `GET /transactions/{id}`: the transaction with the message it came from. */
    func transaction(id: String) async throws -> TransactionDetail
    /** `PATCH /transactions/{id}`: changes the given fields and returns the transaction. */
    func update(id: String, change: TransactionChange) async throws -> Transaction
    /** `DELETE /transactions/{id}`. */
    func delete(id: String) async throws
    /** `GET /chat/messages?around=`: the log around a message, oldest first. */
    func messages(around messageId: String) async throws -> [ConversationMessage]
    /** `POST /imports`: stores the parsed rows and marks the likely duplicates. */
    func upload(_ upload: ImportUpload) async throws -> ImportPreview
    /** `POST /imports/{id}/commit`: saves the chosen rows at once; repeating it is safe. */
    func commit(importId: String, rows: [ImportCommitRow]) async throws -> ImportCommitResult
}
