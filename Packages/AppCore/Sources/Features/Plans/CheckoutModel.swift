import APIClient
import Domain
import Foundation
import Observation

/** Bayar (AKN-06b, AKN-06e): a plan, a period and a payment method; the payment is simulated. */
@MainActor
@Observable
package final class CheckoutModel {
    /** Where the payment stands. */
    package enum Phase: Sendable {
        /** Waiting for Bayar. */
        case ready
        /** Sent. */
        case paying
        /** Paid: the success dialog shows the new subscription. */
        case paid(Subscription)
        /** Refused, with the API's problem. */
        case failed(AppProblem)
    }

    /** The plan bought. */
    package let terms: PlanTerms
    /** Monthly or yearly. */
    package let period: BillingPeriod
    /** The day the subscription would renew: a month or a year from today. */
    package let renewsOn: CalendarDay
    /** QRIS or App Store; QRIS until the person picks. */
    package var paymentMethod = PaymentMethod.qris
    /** Where the payment stands. */
    package private(set) var phase = Phase.ready

    private let service: any PlansService

    /** The checkout of `terms` for `period`, on the WIB day of `now`. */
    package init(terms: PlanTerms, period: BillingPeriod, service: any PlansService, now: Date = Date()) {
        self.terms = terms
        self.period = period
        self.service = service
        renewsOn = period.renewal(after: CalendarDay(now))
    }

    /** What one period costs. */
    package var price: Int { terms.price(for: period) }

    /** Pays (simulated). */
    package func pay() async {
        phase = .paying
        do {
            phase = .paid(try await service.checkout(plan: terms.id, period: period, paymentMethod: paymentMethod))
        } catch {
            phase = .failed(plansProblem(error))
        }
    }
}
