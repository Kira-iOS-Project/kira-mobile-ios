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

    /**
     The account `debtId` as `after` shows it paid off, when the payment's own answer was lost (a
     retry answered `PAYOFF_PAYMENT_ALREADY_RECORDED`): nil unless `before` listed it open and
     `after` lists it paid. With no answer there is no score estimate; the plan's new focus is next.
     */
    package init?(debtId: String, before: ActivePayoffPlan, after: ActivePayoffPlan) {
        guard let was = before.account(debtId), was.status != .paidOff,
            let now = after.account(debtId), now.status == .paidOff
        else { return nil }
        id = debtId
        name = now.name
        position = before.position(of: debtId)
        total = before.accounts.count
        monthlyInstalment = was.monthlyInstalment
        scoreEstimate = nil
        nextAccount = after.focus.map { NextAccount(id: $0.id, name: $0.name) }
    }
}
