/**
 A goal as the device computed it, to create (`POST /goals`) or change (`PATCH /goals/{id}`): the
 kind, its name, the form's inputs (kept so the form opens again as written), what is saved already,
 the monthly deposit, the target with its date, and whether it becomes a budget line. The server
 stores it and checks its ranges; it computes nothing.
 */
package struct GoalDraft: Hashable, Sendable {
    /** What it saves for. */
    package var kind: GoalKind
    /** The name the person gave it. */
    package var name: String
    /** The form's inputs by field; Dana Darurat must send `essentialExpense`. */
    package var inputs: [String: GoalInput]
    /** Tabungan saat ini, whole rupiah. */
    package var initialAmount: Int
    /** Whole rupiah per month. */
    package var monthlyDeposit: Int
    /** Whole rupiah, inflation included. */
    package var targetAmount: Int
    /** The day it aims at. */
    package var targetDate: CalendarDay
    /** Jadikan Pos Budget. */
    package var inBudget: Bool

    /** A draft with the given parts. */
    package init(
        kind: GoalKind, name: String, inputs: [String: GoalInput], initialAmount: Int, monthlyDeposit: Int,
        targetAmount: Int, targetDate: CalendarDay, inBudget: Bool
    ) {
        self.kind = kind
        self.name = name
        self.inputs = inputs
        self.initialAmount = initialAmount
        self.monthlyDeposit = monthlyDeposit
        self.targetAmount = targetAmount
        self.targetDate = targetDate
        self.inBudget = inBudget
    }
}

/** One input of a goal's form, as the API keeps it: a number, a text, a yes or no, or empty. */
package enum GoalInput: Hashable, Sendable {
    /** An amount, a rate or a count. */
    case number(Double)
    /** A name or a choice's key (at most 80 characters). */
    case text(String)
    /** A yes or no. */
    case flag(Bool)
    /** Left empty. */
    case empty
}
