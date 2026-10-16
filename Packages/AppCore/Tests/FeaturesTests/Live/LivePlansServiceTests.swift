import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LivePlansService")
struct LivePlansServiceTests {
    private let subscription = Subscription(
        id: "s-1", plan: .plus, period: .monthly, source: .purchase, price: 29_000, paymentMethod: .qris,
        currentPeriodStart: CalendarDay(year: 2026, month: 10, day: 16),
        renewsOn: CalendarDay(year: 2026, month: 11, day: 16), reminderOn: CalendarDay(year: 2026, month: 11, day: 13),
        cancelAtPeriodEnd: false,
        usage: Usage(
            aiMessages: UsageMeter(used: 3, limit: 300), receipts: UsageMeter(used: 0, limit: 150),
            voiceSeconds: UsageMeter(used: 0, limit: 10_800), resetsOn: CalendarDay(year: 2026, month: 11, day: 16)))

    @Test("GET /plans becomes the catalog and the current plan")
    func plans() async throws {
        let (api, _) = KiraAPI.routed(["GET /api/plans": ok(plansJSON)])
        let catalog = try await LivePlansService(api: api).plans()
        #expect(catalog.plans.map(\.id) == [.free, .plus])
        #expect(
            catalog.plans[1]
                == PlanTerms(
                    id: .plus, monthlyPrice: 29_000, yearlyPrice: 290_000, aiMessages: 300, receipts: 150,
                    voiceSeconds: 10_800, voiceAndImport: true))
        #expect(catalog.current == PlanCatalog.Current(plan: .plus, period: .yearly))
    }

    @Test("checkout, cancel and a new payment method return the subscription")
    func subscriptionCalls() async throws {
        let (api, transport) = KiraAPI.routed([
            "POST /api/billing/checkout": ok(subscriptionJSON()),
            "POST /api/subscription/cancel": ok(subscriptionJSON()),
            "PUT /api/subscription/payment-method": ok(subscriptionJSON(method: "null")),
        ])
        let service = LivePlansService(api: api)
        #expect(try await service.checkout(plan: .plus, period: .monthly, paymentMethod: .appStore) == subscription)
        #expect(
            await transport.sent[0].json == [
                "plan": .string("plus"), "period": .string("monthly"), "paymentMethod": .string("app_store"),
            ])
        #expect(try await service.cancelSubscription() == subscription)
        #expect(try await service.setPaymentMethod(.qris).paymentMethod == nil)
        #expect(await transport.sent[2].json == ["paymentMethod": .string("qris")])
    }

    @Test("GET /subscription; Kira Gratis has none, other problems are thrown")
    func currentSubscription() async throws {
        let (api, _) = KiraAPI.routed(["GET /api/subscription": ok(subscriptionJSON())])
        #expect(try await LivePlansService(api: api).subscription() == subscription)
        let (free, _) = KiraAPI.routed(["GET /api/subscription": problem("SUBSCRIPTION_NOT_FOUND", status: 404)])
        #expect(try await LivePlansService(api: free).subscription() == nil)
        let (failing, _) = KiraAPI.routed(["GET /api/subscription": problem("INTERNAL_ERROR", status: 401)])
        await #expect(throws: AppProblem.self) { try await LivePlansService(api: failing).subscription() }
    }

    @Test("invoices and a Traktir Kira of 1, 3 or 6 months; any other length is refused here")
    func invoicesAndTreat() async throws {
        let (api, transport) = KiraAPI.routed([
            "GET /api/billing/invoices": ok(invoicesJSON),
            "POST /api/billing/gifts": ok(#"{"id":"g-1","months":3,"amount":87000}"#, status: 201),
        ])
        let service = LivePlansService(api: api)
        #expect(
            try await service.invoices() == [
                Invoice(
                    id: "i-1", plan: .plus, period: .yearly, amount: 290_000, paymentMethod: .appStore,
                    periodStart: CalendarDay(year: 2026, month: 10, day: 16))
            ])
        #expect(
            try await service.treat(months: 3, paymentMethod: .qris) == TreatGift(id: "g-1", months: 3, amount: 87_000))
        #expect(await transport.sent[1].json == ["months": .number(3), "paymentMethod": .string("qris")])
        await #expect(throws: AppProblem()) { try await service.treat(months: 2, paymentMethod: .qris) }
    }

    @Test("Beasiswa Kira: an accepted application carries its decision, one in review none")
    func scholarship() async throws {
        let (api, _) = KiraAPI.routed([
            "GET /api/scholarship": ok(scholarshipJSON(application: acceptedApplicationJSON))
        ])
        let overview = try await LivePlansService(api: api).scholarship()
        #expect(!overview.eligible && overview.ineligibleReason == .hasScholarship)
        #expect(overview.quotaRemaining == 1 && overview.quotaTotal == 4)
        let application = try #require(overview.application)
        #expect(application.status == .accepted && application.situations == [.incomeStopped, .medicalCosts])
        #expect(application.decidedAt == CalendarDay(year: 2026, month: 10, day: 17))
        #expect(
            application.grant == CalendarDay(
                year: 2026, month: 10, day: 17)...CalendarDay(year: 2027, month: 1, day: 16))
        #expect(application.extensionFrom == CalendarDay(year: 2027, month: 1, day: 2))
        let (none, _) = KiraAPI.routed(["GET /api/scholarship": ok(scholarshipJSON(application: "null"))])
        #expect(try await LivePlansService(api: none).scholarship().application == nil)
    }

    @Test("Beasiswa Kira before Mode Darurat Utang was ever opened asks to open it first")
    func scholarshipBeforeDebtEmergency() async throws {
        let (api, _) = KiraAPI.routed([
            "GET /api/scholarship": ok(scholarshipJSON(application: "null", reason: "debt_emergency_not_used"))
        ])
        let overview = try await LivePlansService(api: api).scholarship()
        #expect(overview.ineligibleReason == .debtEmergencyNotUsed && overview.needsDebtEmergency)
        #expect(overview.stage == .intro)
    }

    @Test("applying, withdrawing and the account's email")
    func apply() async throws {
        let (api, transport) = KiraAPI.routed([
            "POST /api/scholarship/applications": ok(pendingApplicationJSON, status: 201),
            "DELETE /api/scholarship/applications/current": empty(),
            "GET /api/me": ok(meJSON()),
        ])
        let service = LivePlansService(api: api)
        let application = try await service.apply(situations: [.chasedByLender], story: nil)
        #expect(application.status == .inReview && application.decidedAt == nil && application.grant == nil)
        #expect(await transport.sent[0].json["situations"] == .array([.string("chased_by_lender")]))
        try await service.withdrawApplication()
        #expect(try await service.accountEmail() == "dinda@email.com")
    }
}
