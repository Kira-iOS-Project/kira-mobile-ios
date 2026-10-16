import APIClient
import Domain

/**
 What the Paket, Langganan, Traktir Kira and Beasiswa Kira screens need from the API (CONTRACT.md,
 Billing & Beasiswa). Each call throws an `AppProblem`. The app implements it with the generated
 client; previews and tests pass their own.
 */
package protocol PlansService: Sendable {
    /** `GET /plans`: every plan's terms and the person's plan. */
    func plans() async throws -> PlanCatalog
    /** `POST /billing/checkout`: buys a plan (simulated) and returns the new subscription. */
    func checkout(plan: PlanID, period: BillingPeriod, paymentMethod: PaymentMethod) async throws -> Subscription
    /** `GET /subscription`, or nil on Kira Gratis (404 SUBSCRIPTION_NOT_FOUND). */
    func subscription() async throws -> Subscription?
    /** `POST /subscription/cancel`: ends the subscription at the end of its period. */
    func cancelSubscription() async throws -> Subscription
    /** `PUT /subscription/payment-method`. */
    func setPaymentMethod(_ method: PaymentMethod) async throws -> Subscription
    /** `GET /billing/invoices`, newest first. */
    func invoices() async throws -> [Invoice]
    /** `POST /billing/gifts`: a Traktir Kira of `months` months of Kira Plus (simulated). */
    func treat(months: Int, paymentMethod: PaymentMethod) async throws
    /** `GET /scholarship`. */
    func scholarship() async throws -> ScholarshipOverview
    /** `POST /scholarship/applications`. */
    func apply(situations: [ScholarshipSituation], story: String?) async throws -> ScholarshipApplication
    /** `DELETE /scholarship/applications/current` (Tarik Pengajuan). */
    func withdrawApplication() async throws
    /** The account's email from `GET /me`, which the application form lists as sent along. */
    func accountEmail() async throws -> String
}

/** The problem an error stands for: the API's own, or the generic one for anything else. */
func plansProblem(_ error: any Error) -> AppProblem {
    if let problem = error as? AppProblem { return problem }
    return AppProblem()
}
