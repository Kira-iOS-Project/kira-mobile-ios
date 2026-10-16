/**
 A saved transaction and what the detail screen adds to it, mirroring the API's `Transaction` and
 `TransactionDetail` (CONTRACT.md, Catat). Amounts are whole rupiah.
 */
import Foundation

/** Where a transaction was recorded from: the backend's `TRANSACTION_SOURCE` values. */
package enum TransactionSource: String, CaseIterable, Codable, Sendable {
    case chat, manual, receipt
    case bankImport = "bank_import"
}

/** One saved transaction. */
package struct Transaction: Identifiable, Hashable, Sendable {
    package let id: String
    package let type: TransactionType
    /** Whole rupiah, never negative; `type` says which way it went. */
    package let amount: Int
    package let category: TransactionCategory
    package let name: String
    package let occurredAt: Date
    package let note: String?
    package let source: TransactionSource
    /** The chat message it was read from, for transactions recorded by chat. */
    package let sourceMessageId: String?

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
    package let id: String
    package let body: String
    package let createdAt: Date
    /** The span's bounds in UTF-16 code units, as the server (JavaScript) counts them. */
    package let spanStart: Int?
    package let spanEnd: Int?

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
    package let before: String
    package let highlight: String
    package let after: String
}

/** A transaction with the message it came from, when it came from chat. */
package struct TransactionDetail: Hashable, Sendable {
    package let transaction: Transaction
    package let sourceMessage: SourceQuote?

    package init(transaction: Transaction, sourceMessage: SourceQuote?) {
        self.transaction = transaction
        self.sourceMessage = sourceMessage
    }

    /** The same detail with the transaction replaced, after an edit. */
    package func replacing(_ transaction: Transaction) -> TransactionDetail {
        TransactionDetail(transaction: transaction, sourceMessage: sourceMessage)
    }
}
