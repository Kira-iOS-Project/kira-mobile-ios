/**
 Transactions (tag Catat): Catat Manual, Riwayat and its totals, Detail Transaksi with its edit and
 delete, and Urungkan of a chat save (CAT-03, CAT-04, CAT-07, CAT-08).
 */

extension KiraAPI {
    /** Saves a manual entry; idempotent on `clientId`, and spends no quota. */
    package func createTransaction(_ entry: ManualTransactionInputDTO) async throws -> ManualTransactionSavedDTO {
        let body = Components.Schemas.ManualTransactionInput(
            clientId: entry.clientId, _type: try bridged(entry.type), amount: entry.amount,
            category: try bridged(entry.category), name: entry.name, occurredAt: entry.occurredAt, note: entry.note)
        return try await client.createTransaction(body: .json(body)).saved()
    }

    /** A page of Riwayat, newest first. */
    package func listTransactions(_ query: TransactionQueryDTO = .init()) async throws -> TransactionPageDTO {
        let generated = Operations.ListTransactions.Input.Query(
            from: query.firstDay, to: query.lastDay, _type: try bridged(query.type),
            category: try bridged(query.category), q: query.search, cursor: query.cursor, limit: query.limit)
        return try await client.listTransactions(query: generated).page()
    }

    /** Money out and in from `firstDay` to `lastDay` (`YYYY-MM-DD`, both included; at most a year). */
    package func summarizeTransactions(firstDay: String, lastDay: String) async throws -> TransactionSummaryDTO {
        try await client.summarizeTransactions(query: .init(from: firstDay, to: lastDay)).summary()
    }

    /** One transaction with its source quote. */
    package func getTransaction(id: String) async throws -> TransactionDetailDTO {
        try await client.getTransaction(path: .init(id: id)).detail()
    }

    /** Edits the given fields; a category from the other list turns the transaction the other way. */
    package func updateTransaction(id: String, change: TransactionChangeDTO) async throws -> TransactionDTO {
        let body = Components.Schemas.TransactionUpdate(
            name: change.name, amount: change.amount, category: try bridged(change.category),
            occurredAt: change.occurredAt, note: change.note)
        return try await client.updateTransaction(path: .init(id: id), body: .json(body)).transaction()
    }

    /** Deletes a transaction. */
    package func deleteTransaction(id: String) async throws {
        try await client.deleteTransaction(path: .init(id: id)).deleted()
    }

    /** Urungkan: takes a chat save back within 30 seconds and answers the reply, pending again. */
    package func undoTransactionBatch(batchId: String) async throws -> ChatMessageDTO {
        try await client.undoTransactionBatch(path: .init(batchId: batchId)).message()
    }
}
