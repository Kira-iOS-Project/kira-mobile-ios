/** `GET /subscription`: the paid or granted plan the person has. */
package struct Subscription: Hashable, Sendable {
    /** Where a subscription comes from: the backend's `SUBSCRIPTION_SOURCE` values. */
    package enum Source: String, CaseIterable, Codable, Sendable {
        /** Bought through checkout. */
        case purchase
        /** Granted by Beasiswa Kira. */
        case scholarship
    }

    /** The subscription's id. */
    package let id: String
    /** Kira Muda or Kira Plus. */
    package let plan: PlanID
    /** Monthly or yearly. */
    package let period: BillingPeriod
    /** Bought, or granted by Beasiswa Kira. */
    package let source: Source
    /** The price of one period. */
    package let price: Int
    /** How it is paid; nil for a scholarship. */
    package let paymentMethod: PaymentMethod?
    /** The day the current period began. */
    package let currentPeriodStart: CalendarDay
    /** The day it renews (or ends, once cancelled). */
    package let renewsOn: CalendarDay
    /** The day the reminder email goes out, three days before `renewsOn`. */
    package let reminderOn: CalendarDay
    /** Whether it ends at the end of this period. */
    package let cancelAtPeriodEnd: Bool
    /** The period's use of each quota. */
    package let usage: Usage

    /**
     Whether Beasiswa Kira granted it: free until `renewsOn`, with no payment method to change and
     nothing to cancel (the API answers SUBSCRIPTION_NOT_PAID and SUBSCRIPTION_NOT_CANCELLABLE).
     */
    package var isGrant: Bool { source == .scholarship }

    /** The subscription as the API sends it. */
    package init(
        id: String, plan: PlanID, period: BillingPeriod, source: Source, price: Int,
        paymentMethod: PaymentMethod?, currentPeriodStart: CalendarDay, renewsOn: CalendarDay,
        reminderOn: CalendarDay, cancelAtPeriodEnd: Bool, usage: Usage
    ) {
        self.id = id
        self.plan = plan
        self.period = period
        self.source = source
        self.price = price
        self.paymentMethod = paymentMethod
        self.currentPeriodStart = currentPeriodStart
        self.renewsOn = renewsOn
        self.reminderOn = reminderOn
        self.cancelAtPeriodEnd = cancelAtPeriodEnd
        self.usage = usage
    }
}
