import Domain
import Foundation

/** Plans and the simulated billing (AKN-06 to AKN-09); nothing is ever charged. */

/** Monthly or yearly. */
package enum BillingPeriod: String, CaseIterable, Sendable {
    /** Per month. */
    case monthly
    /** Per year. */
    case yearly
}

/** How a plan is paid (simulated). */
package enum PaymentMethod: String, CaseIterable, Sendable {
    /** QRIS. */
    case qris
    /** App Store. */
    case appStore = "app_store"
}

/** One plan's price and allowances. */
package struct PlanTerms: Hashable, Sendable {
    /** Gratis, Muda or Plus. */
    package let id: PlanID
    /** Rupiah per month. */
    package let monthlyPrice: Int
    /** Rupiah per year. */
    package let yearlyPrice: Int
    /** What a year saves against twelve months. */
    package let yearlySaving: Int
    /** Kira AI chat messages per quota period. */
    package let aiMessages: Int
    /** Receipt scans per quota period. */
    package let receipts: Int
    /** Seconds of voice input per quota period. */
    package let voiceSeconds: Int
    /** Voice input and bank-statement import. */
    package let voiceAndImport: Bool

    init(_ plan: Components.Schemas.Plan) throws {
        id = try bridged(plan.id)
        monthlyPrice = plan.monthlyPrice
        yearlyPrice = plan.yearlyPrice
        yearlySaving = plan.yearlySaving
        aiMessages = plan.aiMessages
        receipts = plan.receipts
        voiceSeconds = plan.voiceSeconds
        voiceAndImport = plan.voiceAndImport
    }
}

/** The three plans and the one in force. */
package struct PlanCatalog: Hashable, Sendable {
    /** Gratis, Muda and Plus, in that order. */
    package let plans: [PlanTerms]
    /** The plan in force. */
    package let current: PlanID
    /** Its billing period; nil on Gratis. */
    package let currentPeriod: BillingPeriod?
}

/** A paid plan, bought or granted by Beasiswa Kira. */
package struct Subscription: Hashable, Sendable {
    /** Its id. */
    package let id: String
    /** Muda or Plus. */
    package let plan: PlanID
    /** Monthly or yearly. */
    package let period: BillingPeriod
    /** Bought or a scholarship. */
    package let source: PlanSource
    /** Rupiah per period; 0 for a scholarship. */
    package let price: Int
    /** How it is paid; nil for a scholarship. */
    package let paymentMethod: PaymentMethod?
    /** When the current period began. */
    package let currentPeriodStart: Date
    /** When it renews or ends (`YYYY-MM-DD`). */
    package let renewsOn: String
    /** When the reminder email goes out, three days before. */
    package let reminderOn: String
    /** Cancelled: it ends on `renewsOn`. */
    package let cancelAtPeriodEnd: Bool
    /** This quota period's usage. */
    package let usage: Usage

    init(_ subscription: Components.Schemas.Subscription) throws {
        id = subscription.id
        plan = try bridged(subscription.plan)
        period = try bridged(subscription.period)
        source = try bridged(subscription.source)
        price = subscription.price
        paymentMethod = try bridged(subscription.paymentMethod)
        currentPeriodStart = subscription.currentPeriodStart
        renewsOn = subscription.renewsOn
        reminderOn = subscription.reminderOn
        cancelAtPeriodEnd = subscription.cancelAtPeriodEnd
        usage = Usage(subscription.usage)
    }
}

/** One simulated payment. */
package struct Invoice: Hashable, Sendable {
    /** Its id. */
    package let id: String
    /** The plan paid for. */
    package let plan: PlanID
    /** Monthly or yearly. */
    package let period: BillingPeriod
    /** Rupiah. */
    package let amount: Int
    /** How it was paid. */
    package let paymentMethod: PaymentMethod
    /** The period it paid for began on (`YYYY-MM-DD`). */
    package let periodStart: String
    /** When it was written. */
    package let createdAt: Date
}

/** Traktir Kira: one, three or six months of Kira Plus for Beasiswa Kira. */
package enum GiftLength: Int, CaseIterable, Sendable {
    /** One month. */
    case oneMonth = 1
    /** Three months. */
    case threeMonths = 3
    /** Six months. */
    case sixMonths = 6
}

/** A gift bought (simulated). */
package struct Gift: Hashable, Sendable {
    /** Its id. */
    package let id: String
    /** Months of Kira Plus. */
    package let months: Int
    /** Rupiah: Plus's monthly price times the months. */
    package let amount: Int
}
