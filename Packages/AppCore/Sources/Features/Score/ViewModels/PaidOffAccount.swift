import Domain

/**
 What Perayaan Lunas (SKR-05) shows for the account a payment settled: its name and place in the
 plan ("Akun 1 dari 3 selesai"), the instalment that leaves the month, the score the engine
 expects, and the account the plan moves to next.
 */
package struct PaidOffAccount: Hashable, Identifiable, Sendable {
    /** The settled account's id. */
    package let id: String
    /** Its name. */
    package let name: String
    /** Its place in the plan, from 1; nil when the plan no longer lists it. */
    package let position: Int?
    /** How many accounts the plan has. */
    package let total: Int
    /** The monthly instalment the person no longer pays. */
    package let monthlyInstalment: Int
    /** The score the engine expects; nil when it sent none. */
    package let scoreEstimate: ScoreEstimate?
    /** The account the plan moves to next; nil when it was the last one. */
    package let nextAccount: NextAccount?

    /** The account `payment` settled, as `plan` listed it before the payment. */
    package init(payment: DebtPayment, plan: ActivePayoffPlan, name: String) {
        id = payment.debtId
        self.name = name
        position = plan.position(of: payment.debtId)
        total = plan.accounts.count
        monthlyInstalment = payment.monthlyInstalment
        scoreEstimate = payment.scoreEstimate
        nextAccount = payment.nextAccount
    }
}
