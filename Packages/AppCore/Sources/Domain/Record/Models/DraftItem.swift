import Foundation

/** A transaction waiting in a draft card (CAT-01, CAT-06): the API's `DraftItem`. */
package struct DraftItem: Identifiable, Hashable, Sendable {
    /** The draft's id. */
    package let id: String
    /** Expense or income. */
    package var type: TransactionType
    /** The name shown on the card. */
    package var name: String
    /** Whole rupiah. */
    package var amount: Int
    /** The category tile. */
    package var category: TransactionCategory
    /** When it happened. */
    package var occurredAt: Date
    /** Where in the person's message it was read, in UTF-16 units; nil for a receipt's item. */
    package let spanStart: Int?
    /** Where the read part ends, in UTF-16 units. */
    package let spanEnd: Int?

    /** A draft with its id. */
    package init(
        id: String, type: TransactionType, name: String, amount: Int, category: TransactionCategory,
        occurredAt: Date, spanStart: Int? = nil, spanEnd: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.amount = amount
        self.category = category
        self.occurredAt = occurredAt
        self.spanStart = spanStart
        self.spanEnd = spanEnd
    }
}

/** A draft as the app sends it with a new message: the API's `DraftInput`, a draft without its id. */
package struct DraftInput: Hashable, Sendable {
    /** Expense or income. */
    package let type: TransactionType
    /** The name. */
    package let name: String
    /** Whole rupiah. */
    package let amount: Int
    /** The category. */
    package let category: TransactionCategory
    /** When it happened. */
    package let occurredAt: Date
    /** Where the read part starts, in UTF-16 units. */
    package let spanStart: Int?
    /** Where the read part ends. */
    package let spanEnd: Int?

    /** A draft to send. */
    package init(
        type: TransactionType, name: String, amount: Int, category: TransactionCategory, occurredAt: Date,
        spanStart: Int?, spanEnd: Int?
    ) {
        self.type = type
        self.name = name
        self.amount = amount
        self.category = category
        self.occurredAt = occurredAt
        self.spanStart = spanStart
        self.spanEnd = spanEnd
    }

    /** The input of a candidate the parser read, at the message's time. */
    package init(_ candidate: DraftCandidate, occurredAt: Date) {
        self.init(
            type: candidate.type, name: candidate.name, amount: candidate.amount, category: candidate.category,
            occurredAt: occurredAt, spanStart: candidate.spanStart, spanEnd: candidate.spanEnd)
    }
}
