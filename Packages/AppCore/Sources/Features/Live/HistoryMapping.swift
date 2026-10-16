import APIClient
import Domain

/**
 Riwayat's, Detail Transaksi's and Impor Mutasi's values read from the API client's DTOs, and the
 query and rows written to it. Days travel as `YYYY-MM-DD` in WIB.
 */
extension Transaction {
    /** One saved transaction. */
    init(_ dto: TransactionDTO) throws {
        self.init(
            id: dto.id, type: dto.type, amount: dto.amount, category: dto.category, name: dto.name,
            occurredAt: dto.occurredAt, note: dto.note, source: try Bridge.value(dto.source),
            sourceMessageId: dto.sourceMessageId)
    }
}

extension TransactionDetail {
    /** A transaction with the message it was read from; a receipt's quote shows its store name. */
    init(_ dto: TransactionDetailDTO) throws {
        self.init(
            transaction: try Transaction(dto.transaction),
            sourceMessage: dto.sourceMessage.map {
                SourceQuote(
                    id: $0.id, body: $0.body ?? "", createdAt: $0.createdAt, spanStart: $0.spanStart,
                    spanEnd: $0.spanEnd)
            })
    }
}

extension TransactionSummary {
    /** The engine's totals of a range and of each day in it. */
    init(_ dto: TransactionSummaryDTO) throws {
        self.init(
            expense: dto.expense, income: dto.income,
            days: try dto.days.map {
                DayTotals(day: try Bridge.day($0.date), expense: $0.expense, income: $0.income)
            })
    }
}

extension TransactionQueryDTO {
    /** Riwayat's filters and page as `GET /transactions` reads them. */
    init(_ query: TransactionQuery) {
        self.init(
            firstDay: query.start.iso, lastDay: query.end.iso, type: query.type, category: query.category,
            search: query.text, cursor: query.cursor, limit: query.limit)
    }
}

extension TransactionChangeDTO {
    /** The fields an edit changes; an empty note clears it. */
    init(_ change: TransactionChange) {
        self.init(
            name: change.name, amount: change.amount, category: change.category, occurredAt: change.occurredAt,
            note: change.note)
    }
}

extension ImportPreview {
    /** The rows the server kept for review, with their duplicate flags. */
    init(_ dto: BankImportDTO) throws {
        self.init(
            id: dto.id, dateFrom: try Bridge.day(dto.dateFrom), dateTo: try Bridge.day(dto.dateTo),
            rows: try dto.rows.map {
                ImportPreviewRow(
                    id: $0.id, day: try Bridge.day($0.date), description: $0.description, amount: $0.amount,
                    type: $0.type, category: $0.category, isDuplicate: $0.isDuplicate)
            })
    }
}
