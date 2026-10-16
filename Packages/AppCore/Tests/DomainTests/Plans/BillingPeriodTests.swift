import Testing

@testable import Domain

@Suite("BillingPeriod")
struct BillingPeriodTests {
    @Test("renews a month or a year on")
    func renewal() {
        let day = CalendarDay(year: 2026, month: 10, day: 15)
        #expect(BillingPeriod.monthly.renewal(after: day) == CalendarDay(year: 2026, month: 11, day: 15))
        #expect(BillingPeriod.yearly.renewal(after: day) == CalendarDay(year: 2027, month: 10, day: 15))
    }
}
