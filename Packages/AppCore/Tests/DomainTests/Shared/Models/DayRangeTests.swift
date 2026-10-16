import Testing

@testable import Domain

@Suite("DayRange")
struct DayRangeTests {
    private func day(_ year: Int, _ month: Int, _ day: Int) -> CalendarDay {
        CalendarDay(year: year, month: month, day: day)
    }

    @Test("writes the first end of a range by what the two ends share")
    func shape() {
        let week = DayRange(first: day(2026, 10, 8), last: day(2026, 10, 14))
        #expect(week.shape == .sameMonth)
        #expect(week.first.day == 8)
        #expect(DayRange(first: day(2026, 9, 28), last: day(2026, 10, 4)).shape == .sameYear)
        #expect(DayRange(first: day(2025, 12, 29), last: day(2026, 1, 4)).shape == .acrossYears)
    }

    @Test("covers a pay period from its payday to the day before the next")
    func period() {
        let period = PayPeriod(start: day(2026, 9, 25), end: day(2026, 10, 24), daysUntilPayday: 10)
        #expect(DayRange(period) == DayRange(first: day(2026, 9, 25), last: day(2026, 10, 24)))
    }
}
