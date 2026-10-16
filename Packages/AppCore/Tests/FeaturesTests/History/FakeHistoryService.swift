import APIClient
import Domain
import Foundation

@testable import Features

/** The API boundary of the history screens, answering from what a test sets. */
actor FakeHistoryService: HistoryService {
    enum Call: Hashable, Sendable {
        case period, summary, transactions, transaction, update, delete, messages, upload, commit
    }

    static let problem = AppProblem(code: "INTERNAL_ERROR", requestId: "req-1")

    var period = Sample.period
    var displayName = "dinda"
    var summary = Sample.summary
    var pages: [String?: TransactionPage] = [nil: TransactionPage(items: Sample.transactions, nextCursor: nil)]
    var detail = Sample.detail
    var messages = Sample.messages
    var preview = Sample.preview
    var commitResult = ImportCommitResult(savedCount: 2, skippedCount: 1)
    var failing: Set<Call> = []
    /** The next `transactions` call waits for `release()`. */
    var holdsNextTransactions = false
    private(set) var queries: [TransactionQuery] = []
    private(set) var changes: [TransactionChange] = []
    private(set) var deleted: [String] = []
    private(set) var uploads: [ImportUpload] = []
    private(set) var commits: [[ImportCommitRow]] = []
    private var held: CheckedContinuation<Void, Never>?

    func configure(_ change: @Sendable (isolated FakeHistoryService) -> Void) { change(self) }
    var isHolding: Bool { held != nil }

    func release() {
        held?.resume()
        held = nil
    }

    func currentAccount() throws -> HistoryAccount {
        try check(.period)
        return HistoryAccount(period: period, displayName: displayName)
    }

    func transactions(_ query: TransactionQuery) async throws -> TransactionPage {
        queries.append(query)
        if holdsNextTransactions {
            holdsNextTransactions = false
            await withCheckedContinuation { held = $0 }
        }
        try check(.transactions)
        return pages[query.cursor] ?? TransactionPage(items: [], nextCursor: nil)
    }

    func summary(from _: CalendarDay, to _: CalendarDay) throws -> TransactionSummary {
        try check(.summary)
        return summary
    }

    func transaction(id _: String) throws -> TransactionDetail {
        try check(.transaction)
        return detail
    }

    func update(id _: String, change: TransactionChange) throws -> Transaction {
        changes.append(change)
        try check(.update)
        return change.applied(to: detail.transaction)
    }

    func delete(id: String) throws {
        try check(.delete)
        deleted.append(id)
    }

    func messages(around _: String) throws -> [ConversationMessage] {
        try check(.messages)
        return messages
    }

    func upload(_ upload: ImportUpload) throws -> ImportPreview {
        uploads.append(upload)
        try check(.upload)
        return preview
    }

    func commit(importId _: String, rows: [ImportCommitRow]) throws -> ImportCommitResult {
        commits.append(rows)
        try check(.commit)
        return commitResult
    }

    private func check(_ call: Call) throws {
        if failing.contains(call) { throw Self.problem }
    }
}

/** Waits until `condition` holds, letting other tasks run in between. */
func eventually(_ condition: () async -> Bool) async {
    for _ in 0..<10_000 where !(await condition()) {
        await Task.yield()
    }
}
