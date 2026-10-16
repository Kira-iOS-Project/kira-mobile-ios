/** What `PATCH /transactions/{id}` changes: only the fields that differ are sent. */
import Foundation

/** The fields of a transaction a person changed; nil leaves a field as it is. */
package struct TransactionChange: Hashable, Sendable {
    package var name: String?
    package var amount: Int?
    package var category: TransactionCategory?
    package var occurredAt: Date?
    package var note: String?

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

    /** True when nothing changes. */
    package var isEmpty: Bool {
        name == nil && amount == nil && category == nil && occurredAt == nil && note == nil
    }

    /** The transaction as it reads after this change. */
    package func applied(to transaction: Transaction) -> Transaction {
        Transaction(
            id: transaction.id, type: transaction.type, amount: amount ?? transaction.amount,
            category: category ?? transaction.category, name: name ?? transaction.name,
            occurredAt: occurredAt ?? transaction.occurredAt, note: note ?? transaction.note,
            source: transaction.source, sourceMessageId: transaction.sourceMessageId)
    }
}
