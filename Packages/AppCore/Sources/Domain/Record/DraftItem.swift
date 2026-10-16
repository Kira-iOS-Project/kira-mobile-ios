import Foundation

/** A transaction waiting in a draft card (CAT-01, CAT-06): the API's `DraftItem`. */
package struct DraftItem: Identifiable, Hashable, Sendable {
    package let id: String
    package var type: TransactionType
    package var name: String
    /** Whole rupiah. */
    package var amount: Int
    package var category: TransactionCategory
    package var occurredAt: Date
    /** Where in the person's message it was read, in UTF-16 units; nil for a receipt's item. */
    package let spanStart: Int?
    package let spanEnd: Int?

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
    package let type: TransactionType
    package let name: String
    package let amount: Int
    package let category: TransactionCategory
    package let occurredAt: Date
    package let spanStart: Int?
    package let spanEnd: Int?

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
