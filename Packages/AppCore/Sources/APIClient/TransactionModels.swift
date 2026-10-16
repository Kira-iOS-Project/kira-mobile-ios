/**
 A recorded transaction as Riwayat and Detail Transaksi show it (CAT-04, CAT-07, CAT-08): the row,
 its source quote, a page of rows, the totals of a range of days, and a manual entry's result.
 Amounts are whole rupiah; `occurredAt` is an instant and day dates are `YYYY-MM-DD` (WIB).
 */
import Domain
import Foundation

/** One transaction. */
package struct TransactionDTO: Hashable, Sendable {
    /** Where it was recorded from: Riwayat's "dari chat, manual, struk, impor". */
    package enum Source: String, Sendable {
        /** Saved from chat drafts. */
        case chat
        /** Catat Manual. */
        case manual
        /** A scanned receipt. */
        case receipt
        /** Impor Mutasi. */
        case bankImport = "bank_import"
    }

    /** The transaction's id. */
    package let id: String
    /** Which way the money went. */
    package let type: TransactionType
    /** Whole rupiah, always positive. */
    package let amount: Int
    /** Its category. */
    package let category: TransactionCategory
    /** "Grab ke Kantor". */
    package let name: String
    /** When it happened. */
    package let occurredAt: Date
    /** The person's note. */
    package let note: String?
    /** Where it was recorded from. */
    package let source: Source
    /** The chat message it was read from. */
    package let sourceMessageId: String?

    init(_ transaction: Components.Schemas.Transaction) throws {
        id = transaction.id
        type = try bridged(transaction._type)
        amount = transaction.amount
        category = try bridged(transaction.category)
        name = transaction.name
        occurredAt = transaction.occurredAt
        note = transaction.note
        source = try bridged(transaction.source)
        sourceMessageId = transaction.sourceMessageId
    }
}

/** The quoted message a transaction was read from, with the part that became it. */
package struct SourceMessageDTO: Hashable, Sendable {
    /** The message's id, for "Riwayat Percakapan" (CAT-08f). */
    package let id: String
    /** Its text, or a receipt's store name. */
    package let body: String?
    /** When it was sent. */
    package let createdAt: Date
    /** Where the highlighted part starts. */
    package let spanStart: Int?
    /** Where it ends. */
    package let spanEnd: Int?
}

/** A transaction with its source quote (Detail Transaksi). */
package struct TransactionDetailDTO: Hashable, Sendable {
    /** The transaction. */
    package let transaction: TransactionDTO
    /** Its source message; nil for a manual entry or an import. */
    package let sourceMessage: SourceMessageDTO?

    init(_ detail: Components.Schemas.TransactionDetail) throws {
        transaction = try TransactionDTO(detail.value1)
        sourceMessage = detail.value2.sourceMessage.map {
            SourceMessageDTO(
                id: $0.id, body: $0.body, createdAt: $0.createdAt, spanStart: $0.spanStart, spanEnd: $0.spanEnd)
        }
    }
}

/** A page of Riwayat, newest first. */
package struct TransactionPageDTO: Hashable, Sendable {
    /** The transactions, newest first. */
    package let items: [TransactionDTO]
    /** Pass as `cursor` for the next page; nil on the last. */
    package let nextCursor: String?

    init(_ page: Components.Schemas.TransactionPage) throws {
        items = try page.items.map(TransactionDTO.init)
        nextCursor = page.nextCursor
    }
}

/** Money out and in over a range of days, and per day. */
package struct TransactionSummaryDTO: Hashable, Sendable {
    /** One day's totals. */
    package struct Day: Hashable, Sendable {
        /** `YYYY-MM-DD`. */
        package let date: String
        /** Money out that day. */
        package let expense: Int
        /** Money in that day. */
        package let income: Int
    }

    /** Money out over the range. */
    package let expense: Int
    /** Money in over the range. */
    package let income: Int
    /** The days that hold a transaction, oldest first. */
    package let days: [Day]

    init(_ summary: Components.Schemas.TransactionSummary) {
        expense = summary.expense
        income = summary.income
        days = summary.days.map { Day(date: $0.date, expense: $0.expense, income: $0.income) }
    }
}

/** A manual entry and Kira's chat note about it (CAT-04b). */
package struct ManualTransactionSavedDTO: Hashable, Sendable {
    /** The saved transaction. */
    package let transaction: TransactionDTO
    /** Kira's manual_saved message. */
    package let message: ChatMessageDTO

    init(_ saved: Components.Schemas.ManualTransactionSaved) throws {
        transaction = try TransactionDTO(saved.transaction)
        message = try ChatMessageDTO(saved.message)
    }
}
