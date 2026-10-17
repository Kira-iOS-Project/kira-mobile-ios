/** What the app sends to save, filter and edit transactions (CAT-04, CAT-07, CAT-08). */
import Domain
import Foundation

/** A Catat Manual entry. */
package struct ManualTransactionInputDTO: Hashable, Sendable {
    /** Chosen by the app, so Coba Lagi never saves twice (CAT-04c). */
    package let clientId: String
    /** Which way the money went. */
    package let type: TransactionType
    /** Whole rupiah, at least Rp1. */
    package let amount: Int
    /** A category of `type`. */
    package let category: TransactionCategory
    /** "Grab ke Kantor". */
    package let name: String
    /** When it happened. */
    package let occurredAt: Date
    /** An optional note. */
    package let note: String?

    /** An entry to save. */
    package init(
        clientId: String, type: TransactionType, amount: Int, category: TransactionCategory, name: String,
        occurredAt: Date, note: String? = nil
    ) {
        self.clientId = clientId
        self.type = type
        self.amount = amount
        self.category = category
        self.name = name
        self.occurredAt = occurredAt
        self.note = note
    }
}

/** Riwayat's filters and page; nil leaves a filter out. Days are `YYYY-MM-DD`, both included. */
package struct TransactionQueryDTO: Hashable, Sendable {
    /** The first day. */
    package var firstDay: String?
    /** The last day. */
    package var lastDay: String?
    /** Money out or in only. */
    package var type: TransactionType?
    /** One category only. */
    package var category: TransactionCategory?
    /** Matches the names. */
    package var search: String?
    /** The `nextCursor` of the page before. */
    package var cursor: String?
    /** The page size; the API's default is 30. */
    package var limit: Int?

    /** A query; every filter is optional. */
    package init(
        firstDay: String? = nil, lastDay: String? = nil, type: TransactionType? = nil,
        category: TransactionCategory? = nil, search: String? = nil, cursor: String? = nil, limit: Int? = nil
    ) {
        self.firstDay = firstDay
        self.lastDay = lastDay
        self.type = type
        self.category = category
        self.search = search
        self.cursor = cursor
        self.limit = limit
    }
}

/** The fields an edit changes; nil keeps a field. A category from the other list flips the type. */
package struct TransactionChangeDTO: Hashable, Sendable {
    /** A new name. */
    package var name: String?
    /** A new amount. */
    package var amount: Int?
    /** A new category. */
    package var category: TransactionCategory?
    /** A new moment. */
    package var occurredAt: Date?
    /** A new note; an empty string clears it (the spec cannot send null). */
    package var note: String?

    /** A change; every field is optional. */
    package init(
        name: String? = nil, amount: Int? = nil, category: TransactionCategory? = nil, occurredAt: Date? = nil,
        note: String? = nil
    ) {
        self.name = name
        self.amount = amount
        self.category = category
        self.occurredAt = occurredAt
        self.note = note
    }
}
