import Domain
import Foundation

/** The canvas's sample data, built once per use so tests share nothing. */
enum PlansFixtures {
    static let free = PlanTerms(
        id: .free, monthlyPrice: 0, yearlyPrice: 0, aiMessages: 30, receipts: 10, voiceSeconds: 0,
        voiceAndImport: false)
    static let young = PlanTerms(
        id: .young, monthlyPrice: 15_000, yearlyPrice: 150_000, aiMessages: 100, receipts: 40, voiceSeconds: 0,
        voiceAndImport: false)
    static let plus = PlanTerms(
        id: .plus, monthlyPrice: 29_000, yearlyPrice: 290_000, aiMessages: 300, receipts: 150,
        voiceSeconds: 10_800, voiceAndImport: true)

    static func catalog(plans: [PlanTerms] = [free, young, plus]) -> PlanCatalog {
        PlanCatalog(plans: plans, current: .init(plan: .free, period: nil))
    }

    static func subscription(cancelled: Bool = false, method: PaymentMethod? = .qris) -> Subscription {
        Subscription(
            id: "sub-1", plan: .plus, period: .monthly, source: .purchase, price: 29_000, paymentMethod: method,
            currentPeriodStart: CalendarDay(year: 2026, month: 10, day: 15),
            renewsOn: CalendarDay(year: 2026, month: 11, day: 15),
            reminderOn: CalendarDay(year: 2026, month: 11, day: 12), cancelAtPeriodEnd: cancelled,
            usage: PlanUsage(
                aiMessages: .init(used: 112, limit: 300), receipts: .init(used: 23, limit: 150),
                voiceSeconds: .init(used: 2520, limit: 10_800), resetsOn: CalendarDay(year: 2026, month: 11, day: 15)))
    }

    static let invoice = Invoice(
        id: "inv-1", plan: .plus, period: .monthly, amount: 29_000, paymentMethod: .qris,
        periodStart: CalendarDay(year: 2026, month: 10, day: 15))

    static func application(status: ScholarshipApplication.Status = .inReview) -> ScholarshipApplication {
        ScholarshipApplication(
            id: "app-1", status: status, situations: [.instalmentsPilingUp, .chasedByLender], story: nil,
            submittedAt: Date(timeIntervalSince1970: 1_792_127_400),
            decideBy: CalendarDay(year: 2026, month: 10, day: 21))
    }

    static func overview(application: ScholarshipApplication? = nil) -> ScholarshipOverview {
        ScholarshipOverview(
            eligible: application == nil, ineligibleReason: application == nil ? nil : .hasOpenApplication,
            quotaRemaining: 42, quotaTotal: 60, application: application)
    }
}
