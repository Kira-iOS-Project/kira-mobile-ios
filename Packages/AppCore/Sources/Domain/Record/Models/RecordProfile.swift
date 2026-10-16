import Foundation

/**
 What Catat needs from `GET /me`: the person's initial for their bubbles, the payday period of the
 header ("Periode 25 September – 24 Oktober 2026"), the plan and its quotas, whether Kira AI may
 read their text, and the last categories for Catat Manual's default (CAT-04).
 */
package struct RecordProfile: Hashable, Sendable {
    /** The name taken from the email. */
    package let displayName: String
    /** The current plan. */
    package let plan: PlanID
    /** The month's quotas. */
    package let usage: Usage
    /** The first day of the payday period. */
    package let periodStart: Date
    /** The last day of the payday period. */
    package let periodEnd: Date
    /** The "Kira AI" consent: off, chat, receipts and voice are not read; Catat Manual still works. */
    package var aiEnabled: Bool
    /** The last expense category used, for Catat Manual. */
    package let lastExpenseCategory: TransactionCategory?
    /** The last income category used. */
    package let lastIncomeCategory: TransactionCategory?

    /** A profile for Catat. */
    package init(
        displayName: String, plan: PlanID, usage: Usage, periodStart: Date, periodEnd: Date, aiEnabled: Bool,
        lastExpenseCategory: TransactionCategory?, lastIncomeCategory: TransactionCategory?
    ) {
        self.displayName = displayName
        self.plan = plan
        self.usage = usage
        self.periodStart = periodStart
        self.periodEnd = periodEnd
        self.aiEnabled = aiEnabled
        self.lastExpenseCategory = lastExpenseCategory
        self.lastIncomeCategory = lastIncomeCategory
    }

    /** The first letter of the name in capitals, beside the person's own bubbles ("D"). */
    package var initial: String { displayName.first.map { String($0).uppercased() } ?? "" }

    /** Whether the plan includes voice input (Kira Plus). */
    package var hasVoice: Bool { usage.voiceSeconds.limit > 0 }
}
