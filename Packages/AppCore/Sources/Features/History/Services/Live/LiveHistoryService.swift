import APIClient
import Domain

/** Riwayat's, Detail Transaksi's, Riwayat Percakapan's and Impor Mutasi's calls over the API client. */
package struct LiveHistoryService: HistoryService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /**
     `GET /me`: the pay period, the name, and whether the plan imports statements: voice and import
     come together (the plan's `voiceAndImport`), so a voice quota means the plan has both.
     */
    package func currentAccount() async throws -> HistoryAccount {
        let account = try await api.getMe()
        return HistoryAccount(
            period: try Bridge.period(account.period), displayName: account.displayName,
            canImport: account.usage.voiceSeconds.limit > 0)
    }

    /** `GET /transactions`. */
    package func transactions(_ query: TransactionQuery) async throws -> TransactionPage {
        let page = try await api.listTransactions(TransactionQueryDTO(query))
        return TransactionPage(items: try page.items.map(Transaction.init), nextCursor: page.nextCursor)
    }

    /** `GET /transactions/summary`. */
    package func summary(from start: CalendarDay, to end: CalendarDay) async throws -> TransactionSummary {
        try TransactionSummary(try await api.summarizeTransactions(firstDay: start.iso, lastDay: end.iso))
    }

    /** `GET /transactions/{id}`. */
    package func transaction(id: String) async throws -> TransactionDetail {
        try TransactionDetail(try await api.getTransaction(id: id))
    }

    /** `PATCH /transactions/{id}`. */
    package func update(id: String, change: TransactionChange) async throws -> Transaction {
        try Transaction(try await api.updateTransaction(id: id, change: TransactionChangeDTO(change)))
    }

    /** `DELETE /transactions/{id}`. */
    package func delete(id: String) async throws {
        try await api.deleteTransaction(id: id)
    }

    /** `GET /chat/messages?around=`. */
    package func messages(around messageId: String) async throws -> [ChatMessage] {
        try await api.listChatMessages(around: messageId).items.map(ChatMessage.init)
    }

    /** `POST /imports`. */
    package func upload(_ upload: ImportUpload) async throws -> ImportPreview {
        let rows = upload.rows.map {
            BankImportUploadRowDTO(
                date: $0.day.iso, description: $0.description, amount: $0.amount, category: $0.category)
        }
        return try ImportPreview(
            try await api.createBankImport(fileName: upload.fileName, fileSize: upload.fileSize, rows: rows))
    }

    /** `POST /imports/{id}/commit`. */
    package func commit(importId: String, rows: [ImportCommitRow]) async throws -> ImportCommitResult {
        let choices = rows.map { BankImportChoiceDTO(id: $0.id, category: $0.category) }
        let result = try await api.commitBankImport(id: importId, rows: choices)
        return ImportCommitResult(savedCount: result.savedCount, skippedCount: result.skippedCount)
    }
}
