import Foundation

/**
 What Catat needs from `GET /me`: the person's initial for their bubbles, the payday period of the
 header ("Periode 25 September – 24 Oktober 2026"), the plan and its quotas, whether Kira AI may
 read their text, and the last categories for Catat Manual's default (CAT-04).
 */
package struct RecordProfile: Hashable, Sendable {
    package let displayName: String
    package let plan: PlanID
    package let usage: Usage
    package let periodStart: Date
    package let periodEnd: Date
    /** The "Kira AI" consent: off, chat, receipts and voice are not read; Catat Manual still works. */
    package let aiEnabled: Bool
    package let lastExpenseCategory: TransactionCategory?
    package let lastIncomeCategory: TransactionCategory?

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
