import Foundation

/** A scheduled charge or a linked debt installment shown in Tagihan & Cicilan. */
package struct RecurringBill: Hashable, Identifiable, Sendable {
    /** Whether this schedule belongs to a bill or a debt account. */
    package enum Kind: String, Hashable, Sendable {
        /** An ordinary recurring bill. */
        case bill
        /** An installment linked to a debt account. */
        case debtInstallment
    }

    /** The server identifier. */
    package let id: String
    /** The name shown in the list. */
    package let name: String
    /** The next amount due, in whole rupiah. */
    package let amount: Int
    /** The server category key. */
    package let category: String
    /** The next scheduled date in WIB. */
    package let nextDueDate: CalendarDay
    /** How often the schedule repeats. */
    package let repeatInterval: String
    /** Whether this is an ordinary bill or a debt installment. */
    package let kind: Kind
    /** The total installment count when this is linked to a debt account. */
    package let installmentsTotal: Int?
    /** The installments still due when this is linked to a debt account. */
    package let installmentsRemaining: Int?
    /** The related account, when this is a debt installment. */
    package let linkedDebtAccountID: String?
    /** The related account's display name, when this is a debt installment. */
    package let linkedDebtName: String?
    /** The server's due-soon decision (five days for bills, ten for installments). */
    package let isDueSoon: Bool
    /** Whether this schedule was paid in the current recurrence period. */
    package let isPaidThisPeriod: Bool

    /** A schedule as returned by the API. */
    package init(
        id: String, name: String, amount: Int, category: String, nextDueDate: CalendarDay,
        repeatInterval: String, kind: Kind, installmentsTotal: Int? = nil, installmentsRemaining: Int? = nil,
        linkedDebtAccountID: String? = nil, linkedDebtName: String? = nil, isDueSoon: Bool = false,
        isPaidThisPeriod: Bool = false
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.category = category
        self.nextDueDate = nextDueDate
        self.repeatInterval = repeatInterval
        self.kind = kind
        self.installmentsTotal = installmentsTotal
        self.installmentsRemaining = installmentsRemaining
        self.linkedDebtAccountID = linkedDebtAccountID
        self.linkedDebtName = linkedDebtName
        self.isDueSoon = isDueSoon
        self.isPaidThisPeriod = isPaidThisPeriod
    }
}
