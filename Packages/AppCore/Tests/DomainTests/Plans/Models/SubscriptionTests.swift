import Testing

@testable import Domain

@Suite("Subscription")
struct SubscriptionTests {
    private func subscription(_ source: Subscription.Source) -> Subscription {
        let day = CalendarDay(year: 2026, month: 10, day: 19)
        let meter = UsageMeter(used: 0, limit: 300)
        return Subscription(
            id: "s-1", plan: .plus, period: .monthly, source: source, price: 0, paymentMethod: nil,
            currentPeriodStart: day, renewsOn: CalendarDay(year: 2027, month: 1, day: 19), reminderOn: day,
            cancelAtPeriodEnd: false,
            usage: Usage(aiMessages: meter, receipts: meter, voiceSeconds: meter, resetsOn: day))
    }

    @Test("a Beasiswa Kira grant is a grant; a bought plan is not")
    func grant() {
        #expect(subscription(.scholarship).isGrant)
        #expect(!subscription(.purchase).isGrant)
    }
}
