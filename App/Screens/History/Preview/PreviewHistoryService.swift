/**
 HistoryService on the canvas's sample, in memory: previews and the app before integration run the
 whole flow on it (filters, search, edit, delete, import). Nothing leaves the device. A row of an
 imported file counts as a duplicate when a sample transaction has the same day, amount and type,
 as the server decides.
 */
import APIClient
import Domain
import Features
import Foundation

actor PreviewHistoryService: HistoryService {
    private var stored = PreviewHistoryData.transactions
    private var pendingImport: ImportPreview?

    func currentAccount() -> HistoryAccount {
        HistoryAccount(period: PreviewHistoryData.period, displayName: "Dinda")
    }

    func transactions(_ query: TransactionQuery) -> TransactionPage {
        var items: [Transaction] = []
        for transaction in stored where matches(transaction, query) { items.append(transaction) }
        return TransactionPage(items: items, nextCursor: nil)
    }

    func summary(from start: CalendarDay, to end: CalendarDay) -> TransactionSummary {
        var days: [CalendarDay: (expense: Int, income: Int)] = [:]
        var expense = 0
        var income = 0
        for transaction in stored where (start...end).contains(transaction.day) {
            var totals = days[transaction.day, default: (0, 0)]
            if transaction.type == .expense {
                totals.expense += transaction.amount
                expense += transaction.amount
            } else {
                totals.income += transaction.amount
                income += transaction.amount
            }
            days[transaction.day] = totals
        }
        let list = days.map { DayTotals(day: $0.key, expense: $0.value.expense, income: $0.value.income) }
        return TransactionSummary(expense: expense, income: income, days: list)
    }

    func transaction(id: String) throws -> TransactionDetail {
        guard let transaction = stored.first(where: { $0.id == id }) else {
            throw AppProblem(code: "TRANSACTION_NOT_FOUND")
        }
        let quote = PreviewHistoryData.spans[id].map { span in
            SourceQuote(
                id: transaction.sourceMessageId ?? id, body: span.message, createdAt: span.sentAt,
                spanStart: span.start,
                spanEnd: span.end)
        }
        return TransactionDetail(transaction: transaction, sourceMessage: quote)
    }

    func update(id: String, change: TransactionChange) throws -> Transaction {
        guard let index = stored.firstIndex(where: { $0.id == id }) else {
            throw AppProblem(code: "TRANSACTION_NOT_FOUND")
        }
        stored[index] = change.applied(to: stored[index])
        return stored[index]
    }

    func delete(id: String) {
        stored.removeAll { $0.id == id }
    }

    func messages(around _: String) -> [ConversationMessage] {
        PreviewHistoryData.messages
    }

    func upload(_ upload: ImportUpload) -> ImportPreview {
        let rows = upload.rows.enumerated().map { index, row in
            let type: TransactionType = row.amount < 0 ? .expense : .income
            let amount = abs(row.amount)
            let isDuplicate = stored.contains { $0.day == row.day && $0.amount == amount && $0.type == type }
            return ImportPreviewRow(
                id: "row-\(index)", day: row.day, description: row.description, amount: amount, type: type,
                category: row.category, isDuplicate: isDuplicate)
        }
        let days = rows.map(\.day)
        let preview = ImportPreview(
            id: "import-1", dateFrom: days.min() ?? PreviewHistoryData.today,
            dateTo: days.max() ?? PreviewHistoryData.today,
            rows: rows)
        pendingImport = preview
        return preview
    }

    /** Saves the chosen rows as transactions, newest first among the rest. */
    func commit(importId _: String, rows: [ImportCommitRow]) -> ImportCommitResult {
        let all = pendingImport?.rows ?? []
        for chosen in rows {
            guard let row = all.first(where: { $0.id == chosen.id }) else { continue }
            let saved = Transaction(
                id: "imported-\(row.id)", type: row.type, amount: row.amount, category: chosen.category,
                name: row.description, occurredAt: PreviewHistoryData.at(row.day, 12, 0), source: .bankImport)
            let index = stored.firstIndex { $0.occurredAt < saved.occurredAt } ?? stored.endIndex
            stored.insert(saved, at: index)
        }
        pendingImport = nil
        return ImportCommitResult(savedCount: rows.count, skippedCount: all.count - rows.count)
    }

    private func matches(_ transaction: Transaction, _ query: TransactionQuery) -> Bool {
        guard (query.start...query.end).contains(transaction.day) else { return false }
        if let type = query.type, transaction.type != type { return false }
        if let category = query.category, transaction.category != category { return false }
        if let text = query.text, !transaction.name.localizedCaseInsensitiveContains(text) { return false }
        return true
    }
}
