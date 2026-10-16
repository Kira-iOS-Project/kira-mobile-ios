/** One line of Riwayat Tagihan (`GET /billing/invoices`). */
package struct Invoice: Hashable, Identifiable, Sendable {
    /** The invoice's id. */
    package let id: String
    /** The plan paid for. */
    package let plan: PlanID
    /** The period paid for. */
    package let period: BillingPeriod
    /** What was paid. */
    package let amount: Int
    /** How it was paid. */
    package let paymentMethod: PaymentMethod
    /** The first day of the period it pays for. */
    package let periodStart: CalendarDay

    /** The invoice as the API sends it. */
    package init(
        id: String, plan: PlanID, period: BillingPeriod, amount: Int, paymentMethod: PaymentMethod,
        periodStart: CalendarDay
    ) {
        self.id = id
        self.plan = plan
        self.period = period
        self.amount = amount
        self.paymentMethod = paymentMethod
        self.periodStart = periodStart
    }
}
