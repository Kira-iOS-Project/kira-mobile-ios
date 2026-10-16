import APIClient
import Domain
import Features

/** What the screens sent, in order. */
actor PlansCallLog {
    private(set) var calls: [String] = []

    func record(_ call: String) {
        calls.append(call)
    }
}

/** A PlansService with canned results: the system boundary the screen models talk to. */
struct FakePlansService: PlansService {
    var plansResult: Result<PlanCatalog, AppProblem> = .success(PlansFixtures.catalog())
    var subscriptionResult: Result<Subscription?, AppProblem> = .success(PlansFixtures.subscription())
    var changeResult: Result<Subscription, AppProblem> = .success(PlansFixtures.subscription())
    var invoicesResult: Result<[Invoice], AppProblem> = .success([PlansFixtures.invoice])
    var treatResult: Result<Void, AppProblem> = .success(())
    var scholarshipResult: Result<ScholarshipOverview, AppProblem> = .success(PlansFixtures.overview())
    var applyResult: Result<ScholarshipApplication, AppProblem> = .success(PlansFixtures.application())
    var withdrawResult: Result<Void, AppProblem> = .success(())
    var emailResult: Result<String, AppProblem> = .success("dinda@email.com")
    /** How many email loads fail with `INTERNAL_ERROR` before `emailResult` answers (Coba Lagi). */
    var emailFailures = 0
    let log = PlansCallLog()

    func plans() async throws -> PlanCatalog {
        await log.record("plans")
        return try plansResult.get()
    }

    func checkout(plan: PlanID, period: BillingPeriod, paymentMethod: PaymentMethod) async throws -> Subscription {
        await log.record("checkout \(plan.rawValue) \(period.rawValue) \(paymentMethod.rawValue)")
        return try changeResult.get()
    }

    func subscription() async throws -> Subscription? {
        await log.record("subscription")
        return try subscriptionResult.get()
    }

    func cancelSubscription() async throws -> Subscription {
        await log.record("cancel")
        return try changeResult.get()
    }

    func setPaymentMethod(_ method: PaymentMethod) async throws -> Subscription {
        await log.record("method \(method.rawValue)")
        return try changeResult.get()
    }

    func invoices() async throws -> [Invoice] {
        await log.record("invoices")
        return try invoicesResult.get()
    }

    func treat(months: Int, paymentMethod: PaymentMethod) async throws {
        await log.record("treat \(months) \(paymentMethod.rawValue)")
        return try treatResult.get()
    }

    func scholarship() async throws -> ScholarshipOverview {
        await log.record("scholarship")
        return try scholarshipResult.get()
    }

    func apply(situations: [ScholarshipSituation], story: String?) async throws -> ScholarshipApplication {
        await log.record("apply \(situations.map(\.rawValue).joined(separator: ",")) \(story ?? "-")")
        return try applyResult.get()
    }

    func withdrawApplication() async throws {
        await log.record("withdraw")
        try withdrawResult.get()
    }

    func accountEmail() async throws -> String {
        await log.record("email")
        if await log.calls.count(where: { $0 == "email" }) <= emailFailures { throw problem("INTERNAL_ERROR") }
        return try emailResult.get()
    }
}

/** A problem with a code, as the API sends it. */
func problem(_ code: String) -> AppProblem {
    AppProblem(code: code, requestId: "req-1")
}
