import APIClient
import Domain

/** Paket, Langganan, Traktir Kira and Beasiswa Kira's calls over the API client. */
package struct LivePlansService: PlansService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /plans`. */
    package func plans() async throws -> PlanCatalog {
        try PlanCatalog(try await api.listPlans())
    }

    /** `POST /billing/checkout` (simulated). */
    package func checkout(plan: PlanID, period: BillingPeriod, paymentMethod: PaymentMethod) async throws
        -> Subscription
    {
        let dto = try await api.checkout(
            plan: plan, period: try Bridge.value(period), paymentMethod: try Bridge.value(paymentMethod))
        return try Subscription(dto)
    }

    /** `GET /subscription`; nil on Kira Gratis (`SUBSCRIPTION_NOT_FOUND`). */
    package func subscription() async throws -> Subscription? {
        do {
            return try Subscription(try await api.getSubscription())
        } catch let problem as AppProblem where problem.knownCode == .subscriptionNotFound {
            return nil
        }
    }

    /** `POST /subscription/cancel`. */
    package func cancelSubscription() async throws -> Subscription {
        try Subscription(try await api.cancelSubscription())
    }

    /** `PUT /subscription/payment-method`. */
    package func setPaymentMethod(_ method: PaymentMethod) async throws -> Subscription {
        try Subscription(try await api.changePaymentMethod(try Bridge.value(method)))
    }

    /** `GET /billing/invoices`, newest first as the API lists them. */
    package func invoices() async throws -> [Invoice] {
        try await api.listInvoices().map(Invoice.init)
    }

    /** `POST /billing/gifts` (simulated); 1, 3 or 6 months. */
    package func treat(months: Int, paymentMethod: PaymentMethod) async throws -> TreatGift {
        guard let length = GiftLengthDTO(rawValue: months) else { throw AppProblem() }
        let gift = try await api.giftMonths(length, paymentMethod: try Bridge.value(paymentMethod))
        return TreatGift(id: gift.id, months: gift.months, amount: gift.amount)
    }

    /** `GET /scholarship`. */
    package func scholarship() async throws -> ScholarshipOverview {
        try ScholarshipOverview(try await api.getScholarship())
    }

    /** `POST /scholarship/applications`. */
    package func apply(situations: [ScholarshipSituation], story: String?) async throws -> ScholarshipApplication {
        let dto = try await api.applyForScholarship(
            situations: try situations.map { try Bridge.value($0) }, story: story)
        return try ScholarshipApplication(dto)
    }

    /** `DELETE /scholarship/applications/current`. */
    package func withdrawApplication() async throws {
        try await api.withdrawScholarshipApplication()
    }

    /** The account's email from `GET /me`. */
    package func accountEmail() async throws -> String {
        try await api.getMe().email
    }
}
