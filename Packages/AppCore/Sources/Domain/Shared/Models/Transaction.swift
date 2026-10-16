/**
 A saved transaction and what the detail screen adds to it, mirroring the API's `Transaction` and
 `TransactionDetail` (CONTRACT.md, Catat). Amounts are whole rupiah.
 */
import Foundation

/** Where a transaction was recorded from: the backend's `TRANSACTION_SOURCE` values. */
package enum TransactionSource: String, CaseIterable, Codable, Sendable {
    /** Read from a chat message, written by hand, or read from a receipt. */
    case chat, manual, receipt
    /** Imported from a bank statement. */
    case bankImport = "bank_import"
}

/** One saved transaction. */
package struct Transaction: Identifiable, Hashable, Sendable {
    /** The server's id. */
    package let id: String
    /** Money out or money in. */
    package let type: TransactionType
    /** Whole rupiah, never negative; `type` says which way it went. */
    package let amount: Int
    /** The category it is filed under. */
    package let category: TransactionCategory
    /** What the person called it. */
    package let name: String
    /** When it happened. */
    package let occurredAt: Date
    /** The person's note, if any. */
    package let note: String?
    /** How it was recorded. */
    package let source: TransactionSource
    /** The chat message it was read from, for transactions recorded by chat. */
    package let sourceMessageId: String?

    /** A transaction with the given fields. */
    package init(
        id: String, type: TransactionType, amount: Int, category: TransactionCategory, name: String,
        occurredAt: Date, note: String? = nil, source: TransactionSource, sourceMessageId: String? = nil
    ) {
        self.id = id
        self.type = type
        self.amount = amount
        self.category = category
        self.name = name
        self.occurredAt = occurredAt
        self.note = note
        self.source = source
        self.sourceMessageId = sourceMessageId
    }

    /** The WIB day it happened on. */
    package var day: CalendarDay { CalendarDay(occurredAt) }
}

/** The chat message a transaction was read from, with the span that became the transaction. */
package struct SourceQuote: Hashable, Sendable {
    /** The message's id. */
    package let id: String
    /** The message as the person wrote it. */
    package let body: String
    /** When the message was sent. */
    package let createdAt: Date
    /** The span's bounds in UTF-16 code units, as the server (JavaScript) counts them. */
    package let spanStart: Int?
    /** The span's end, exclusive. */
    package let spanEnd: Int?

    /** A source message with its span. */
    package init(id: String, body: String, createdAt: Date, spanStart: Int?, spanEnd: Int?) {
        self.id = id
        self.body = body
        self.createdAt = createdAt
        self.spanStart = spanStart
        self.spanEnd = spanEnd
    }

    /**
     The message cut around the highlighted span. A missing, reversed or out-of-range span
     highlights nothing; a span that would split a character is widened to whole characters.
     */
    package var parts: QuoteParts {
        guard let spanStart, let spanEnd, spanStart >= 0, spanStart < spanEnd, spanEnd <= body.utf16.count else {
            return QuoteParts(before: body, highlight: "", after: "")
        }
        var start = body.startIndex
        var end = body.endIndex
        var offset = 0
        for index in body.indices {
            if offset <= spanStart { start = index }
            if offset >= spanEnd {
                end = index
                break
            }
            offset += body[index].utf16.count
        }
        return QuoteParts(
            before: String(body[..<start]), highlight: String(body[start..<end]), after: String(body[end...]))
    }
}

/** A message split around its highlighted span. */
package struct QuoteParts: Hashable, Sendable {
    /** The text before the span. */
    package let before: String
    /** The span itself. */
    package let highlight: String
    /** The text after the span. */
    package let after: String
}

/** A transaction with the message it came from, when it came from chat. */
package struct TransactionDetail: Hashable, Sendable {
    /** The transaction. */
    package let transaction: Transaction
    /** The message it was read from; nil when it was not recorded by chat. */
    package let sourceMessage: SourceQuote?

    /** A transaction with its source message. */
    package init(transaction: Transaction, sourceMessage: SourceQuote?) {
        self.transaction = transaction
        self.sourceMessage = sourceMessage
    }

    /** The same detail with the transaction replaced, after an edit. */
    package func replacing(_ transaction: Transaction) -> TransactionDetail {
        TransactionDetail(transaction: transaction, sourceMessage: sourceMessage)
    }
}
