/**
 A goal in a list (`GET /goals`, `GET /plan`): what it saves for, how much is in it, the monthly
 deposit and the date it aims at. Amounts are whole rupiah; dates are days in WIB.
 */
package struct GoalSummary: Hashable, Identifiable, Sendable {
    /** The server's id. */
    package let id: String
    /** What it saves for. */
    package var kind: GoalKind
    /** The name the person gave it. */
    package var name: String
    /** The amount it aims at, inflation included. */
    package var targetAmount: Int
    /** The day it aims to be reached. */
    package var targetDate: CalendarDay
    /** The deposit the plan asks for each month. */
    package var monthlyDeposit: Int
    /** What is in it so far. */
    package var savedAmount: Int

    /** A goal with the given parts. */
    package init(
        id: String, kind: GoalKind, name: String, targetAmount: Int, targetDate: CalendarDay, monthlyDeposit: Int,
        savedAmount: Int
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.targetAmount = targetAmount
        self.targetDate = targetDate
        self.monthlyDeposit = monthlyDeposit
        self.savedAmount = savedAmount
    }
}

/**
 One goal in full (`GET /goals/{id}`): its summary, the form's inputs as written, what was saved
 before it started, whether it is a budget line, its deposits (newest first) and, for Dana Darurat,
 its milestones.
 */
package struct GoalDetail: Hashable, Identifiable, Sendable {
    /** What a list shows of it. */
    package var summary: GoalSummary
    /** The form's inputs by field, so the form opens again as written. */
    package var inputs: [String: GoalInput]
    /** Tabungan saat ini, when the goal was made. */
    package var initialAmount: Int
    /** Whether Jadikan Pos Budget made it a budget line. */
    package var inBudget: Bool
    /** The deposits, newest first. */
    package var deposits: [GoalDeposit]
    /** Dana Darurat's milestones; empty for other kinds. */
    package var milestones: [GoalMilestone]

    /** The server's id. */
    package var id: String { summary.id }

    /** A goal with the given parts; no inputs, deposits or milestones unless told otherwise. */
    package init(
        summary: GoalSummary, inputs: [String: GoalInput] = [:], initialAmount: Int = 0, inBudget: Bool = false,
        deposits: [GoalDeposit] = [], milestones: [GoalMilestone] = []
    ) {
        self.summary = summary
        self.inputs = inputs
        self.initialAmount = initialAmount
        self.inBudget = inBudget
        self.deposits = deposits
        self.milestones = milestones
    }
}

/** Money put into a goal on a day (`POST /goals/{id}/deposits`). */
package struct GoalDeposit: Hashable, Identifiable, Sendable {
    /** The id the app gave it, so a retry lands once. */
    package let id: String
    /** Whole rupiah. */
    package let amount: Int
    /** The day it went in. */
    package let depositedOn: CalendarDay

    /** A deposit of `amount` on `depositedOn`. */
    package init(id: String, amount: Int, depositedOn: CalendarDay) {
        self.id = id
        self.amount = amount
        self.depositedOn = depositedOn
    }
}

/** A step on Dana Darurat's way: the amount it stands for and the day it was reached, if it was. */
package struct GoalMilestone: Hashable, Sendable {
    /** Which step it is. */
    package let key: MilestoneKey
    /** Whole rupiah. */
    package let amount: Int
    /** The day it was reached; nil until then. */
    package let reachedOn: CalendarDay?

    /** The step `key` at `amount`, reached on `reachedOn` if it was. */
    package init(key: MilestoneKey, amount: Int, reachedOn: CalendarDay?) {
        self.key = key
        self.amount = amount
        self.reachedOn = reachedOn
    }
}

/** A Dana Darurat milestone, as `GET /goals/{id}` names it. */
package enum MilestoneKey: String, CaseIterable, Hashable, Sendable {
    /** A week of essential spending (pokok × 7 ÷ 30). */
    case oneWeek = "one_week"
    /** A month of essential spending. */
    case oneMonth = "one_month"
    /** Three months. */
    case threeMonths = "three_months"
    /** The goal's own target. */
    case target
}
