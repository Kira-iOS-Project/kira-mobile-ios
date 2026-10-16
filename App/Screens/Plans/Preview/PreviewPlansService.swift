/**
 The canvas's sample data behind PlansService, so the Paket, Langganan and Beasiswa Kira screens run
 in previews and in the app before the API client implements the protocol. It keeps what the
 screens change (a checkout, a cancel, an application) for as long as it lives.
 */
import APIClient
import Domain
import Features
import Foundation

actor PreviewPlansService: PlansService {
    private var plan = PlanID.plus
    private var current: Subscription? = PreviewPlansData.subscription
    private var application: ScholarshipApplication?

    init(onFreePlan: Bool = false, application: ScholarshipApplication? = nil) {
        if onFreePlan {
            plan = .free
            current = nil
        }
        self.application = application
    }

    func plans() throws -> PlanCatalog {
        PlanCatalog(plans: PreviewPlansData.terms, current: .init(plan: plan, period: current?.period))
    }

    func checkout(plan: PlanID, period: BillingPeriod, paymentMethod: PaymentMethod) throws -> Subscription {
        let terms = PreviewPlansData.terms.first { $0.id == plan } ?? PreviewPlansData.terms[2]
        let start = PreviewPlansData.today
        let renews = period.renewal(after: start)
        let subscription = Subscription(
            id: "sub-preview", plan: plan, period: period, source: .purchase, price: terms.price(for: period),
            paymentMethod: paymentMethod, currentPeriodStart: start, renewsOn: renews,
            reminderOn: renews.adding(days: -3),
            cancelAtPeriodEnd: false, usage: PreviewPlansData.usage(resetsOn: renews))
        self.plan = plan
        current = subscription
        return subscription
    }

    func subscription() throws -> Subscription? { current }

    func cancelSubscription() throws -> Subscription {
        try change { $0.cancelAtPeriodEnd = true }
    }

    func setPaymentMethod(_ method: PaymentMethod) throws -> Subscription {
        try change { $0.paymentMethod = method }
    }

    func invoices() throws -> [Invoice] {
        [10, 9, 8].map { month in
            Invoice(
                id: "inv-\(month)", plan: .plus, period: .monthly, amount: 29_000, paymentMethod: .qris,
                periodStart: CalendarDay(year: 2026, month: month, day: 15))
        }
    }

    func treat(months: Int, paymentMethod _: PaymentMethod) throws -> TreatGift {
        TreatGift(id: "gift-preview", months: months, amount: 29_000 * months)
    }

    func scholarship() throws -> ScholarshipOverview {
        let open = application.map { $0.status != .withdrawn } ?? false
        return ScholarshipOverview(
            eligible: !open, ineligibleReason: open ? .hasOpenApplication : nil, quotaRemaining: 42, quotaTotal: 60,
            application: application)
    }

    func apply(situations: [ScholarshipSituation], story: String?) throws -> ScholarshipApplication {
        let sent = ScholarshipApplication(
            id: "app-preview", status: .inReview, situations: situations, story: story,
            submittedAt: PreviewPlansData.sentAt,
            decideBy: PreviewPlansData.today.adding(days: 5))
        application = sent
        return sent
    }

    func withdrawApplication() throws {
        application = nil
    }

    func accountEmail() throws -> String { "dinda@email.com" }

    private func change(_ edit: (inout PreviewPlansData.Draft) -> Void) throws -> Subscription {
        guard let current else { throw AppProblem(code: "SUBSCRIPTION_NOT_FOUND") }
        var draft = PreviewPlansData.Draft(current)
        edit(&draft)
        let changed = draft.subscription
        self.current = changed
        return changed
    }
}
