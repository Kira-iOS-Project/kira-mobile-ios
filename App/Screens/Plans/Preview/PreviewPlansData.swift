/** The boards' sample values: prices, Langganan on 16 October 2026, an accepted scholarship. */
import Domain
import Foundation

nonisolated enum PreviewPlansData {
    /** The boards' today: 16 October 2026. */
    static let today = CalendarDay(year: 2026, month: 10, day: 16)
    /** 16 October 2026, 12.10 WIB. */
    static let sentAt = Date(timeIntervalSince1970: 1_792_127_400)

    static let terms = [
        PlanTerms(
            id: .free, monthlyPrice: 0, yearlyPrice: 0, aiMessages: 30, receipts: 10, voiceSeconds: 0,
            voiceAndImport: false),
        PlanTerms(
            id: .young, monthlyPrice: 15_000, yearlyPrice: 150_000, aiMessages: 100, receipts: 40, voiceSeconds: 0,
            voiceAndImport: false),
        PlanTerms(
            id: .plus, monthlyPrice: 29_000, yearlyPrice: 290_000, aiMessages: 300, receipts: 150,
            voiceSeconds: 10_800, voiceAndImport: true),
    ]

    static let subscription = Subscription(
        id: "sub-preview", plan: .plus, period: .monthly, source: .purchase, price: 29_000, paymentMethod: .qris,
        currentPeriodStart: CalendarDay(year: 2026, month: 10, day: 15),
        renewsOn: CalendarDay(year: 2026, month: 11, day: 15), reminderOn: CalendarDay(year: 2026, month: 11, day: 12),
        cancelAtPeriodEnd: false, usage: usage(resetsOn: CalendarDay(year: 2026, month: 11, day: 15)))

    /** BeasiswaKiraDiterima: sent 16 October 2026 at 12.10 WIB, Kira Plus 19 October to 19 January. */
    static let acceptedApplication = ScholarshipApplication(
        id: "app-preview", status: .accepted, situations: [.instalmentsPilingUp, .chasedByLender], story: nil,
        submittedAt: sentAt, decideBy: CalendarDay(year: 2026, month: 10, day: 21),
        decision: .init(
            decidedAt: CalendarDay(year: 2026, month: 10, day: 19),
            grantStart: CalendarDay(year: 2026, month: 10, day: 19),
            grantEnd: CalendarDay(year: 2027, month: 1, day: 19),
            extensionFrom: CalendarDay(year: 2027, month: 1, day: 5)))

    static func usage(resetsOn: CalendarDay) -> Usage {
        Usage(
            aiMessages: .init(used: 112, limit: 300), receipts: .init(used: 23, limit: 150),
            voiceSeconds: .init(used: 42 * 60, limit: 10_800), resetsOn: resetsOn)
    }

    /** A subscription to change one field of. */
    struct Draft {
        private let base: Subscription
        var paymentMethod: PaymentMethod?
        var cancelAtPeriodEnd: Bool

        init(_ base: Subscription) {
            self.base = base
            paymentMethod = base.paymentMethod
            cancelAtPeriodEnd = base.cancelAtPeriodEnd
        }

        var subscription: Subscription {
            Subscription(
                id: base.id, plan: base.plan, period: base.period, source: base.source, price: base.price,
                paymentMethod: paymentMethod, currentPeriodStart: base.currentPeriodStart, renewsOn: base.renewsOn,
                reminderOn: base.reminderOn, cancelAtPeriodEnd: cancelAtPeriodEnd, usage: base.usage)
        }
    }
}
