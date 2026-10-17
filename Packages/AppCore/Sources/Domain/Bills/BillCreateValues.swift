import Foundation

/** How often a recurring bill repeats. */
package enum BillRepeatInterval: String, CaseIterable, Hashable, Sendable {
    /** Every week. */
    case weekly
    /** Every month. */
    case monthly
    /** Every year. */
    case yearly
}

/** An owner-scoped debt account offered by the recurring-bill form. */
package struct BillDebtAccount: Identifiable, Hashable, Sendable {
    /** The server id of the account. */
    package let id: String
    /** The name the person gave the account. */
    package let name: String

    /** Creates a linked-account choice. */
    package init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

/** The values the owner submits to create one recurring bill. */
package struct BillCreateRequest: Hashable, Sendable {
    /** The trimmed schedule name. */
    package let name: String
    /** The whole-rupiah amount. */
    package let amount: Int
    /** The expense category. */
    package let category: TransactionCategory
    /** The first due date in WIB. */
    package let nextDueDate: CalendarDay
    /** The repetition interval. */
    package let repeatInterval: BillRepeatInterval
    /** The owner debt account, when this schedule is an installment. */
    package let linkedDebtAccountID: String?
    /** The idempotency key kept stable when the same form is retried. */
    package let clientID: UUID

    /** A valid submission as the form prepares it. */
    package init(
        name: String, amount: Int, category: TransactionCategory, nextDueDate: CalendarDay,
        repeatInterval: BillRepeatInterval, linkedDebtAccountID: String?, clientID: UUID
    ) {
        self.name = name
        self.amount = amount
        self.category = category
        self.nextDueDate = nextDueDate
        self.repeatInterval = repeatInterval
        self.linkedDebtAccountID = linkedDebtAccountID
        self.clientID = clientID
    }
}
