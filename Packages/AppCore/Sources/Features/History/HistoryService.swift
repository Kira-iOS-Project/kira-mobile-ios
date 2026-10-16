/**
 The calls behind Riwayat, Detail Transaksi, Riwayat Percakapan and Impor Mutasi (CAT-07 to CAT-12),
 in Domain values (CONTRACT.md, Catat). The integrator implements it with the generated client;
 every call throws an `AppProblem` when the API refuses it.
 */
import Domain

/** The history and import calls. */
package protocol HistoryService: Sendable {
    /** `GET /me`: the current payday period and the person's display name. */
    func currentAccount() async throws -> HistoryAccount
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

/** What the history screens read of `GET /me`. */
package struct HistoryAccount: Hashable, Sendable {
    /** The current payday period. */
    package let period: PayPeriod
    /** The name Kira calls the person, from their email ("dinda@…" is Dinda). */
    package let displayName: String

    /** The account's period and name. */
    package init(period: PayPeriod, displayName: String) {
        self.period = period
        self.displayName = displayName
    }

    /** The initial beside the person's own chat bubbles; nil for an empty name. */
    package var initial: String? {
        displayName.first.map { String($0).uppercased() }
    }
}
