import Foundation

/**
 One debt the person adds in the health check (ONB-11b): its kind, a name they choose, what is
 left to pay, the monthly instalment and, when it has one, how many months are left.
 */
package struct DebtEntry: Identifiable, Hashable, Sendable {
    /** Identifies the row while the quiz is open; never sent. */
    package let id: UUID
    /** The kind of debt. */
    package var kind: DebtKind
    /** The name the person gave it ("Paylater A"). */
    package var name: String
    /** What is left to pay, in whole rupiah. */
    package var remaining: Int
    /** The instalment each month, in whole rupiah. */
    package var monthlyInstalment: Int
    /** Months left to pay, when the instalment has an end. */
    package var remainingTenorMonths: Int?

    /** A debt with every field given; a new `id` unless one is passed. */
    package init(
        id: UUID = UUID(), kind: DebtKind, name: String, remaining: Int, monthlyInstalment: Int,
        remainingTenorMonths: Int? = nil
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.remaining = remaining
        self.monthlyInstalment = monthlyInstalment
        self.remainingTenorMonths = remainingTenorMonths
    }
}
