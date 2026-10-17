import Testing

@testable import Domain

@Suite("WeeklySummaryReading")
struct WeeklySummaryReadingTests {
    private let start = CalendarDay(year: 2026, month: 10, day: 8)

    private func week(_ amounts: [Int], previous: Int, categories: [(TransactionCategory, Int)]) -> WeeklySummary {
        WeeklySummary(
            start: start, end: start.adding(days: 6), total: amounts.reduce(0, +), previousTotal: previous,
            days: amounts.enumerated().map { DaySpending(day: start.adding(days: $0), amount: $1) },
            categories: categories.map { CategorySpending(category: $0, amount: $1) })
    }

    private var boardWeek: WeeklySummary {
        week(
            [165_000, 240_000, 310_000, 280_000, 95_000, 140_000, 155_000], previous: 1_505_000,
            categories: [(.food, 640_000), (.transport, 285_000), (.shopping, 250_000), (.entertainment, 210_000)])
    }

    @Test("the board: Rp120.000 less, Sabtu busiest, Senin quietest, the weekend heaviest, 46/21/18/15")
    func board() {
        let reading = WeeklySummaryReading(boardWeek)
        #expect(reading.comparison == .less(120_000))
        #expect(reading.busiest == DaySpending(day: CalendarDay(year: 2026, month: 10, day: 10), amount: 310_000))
        #expect(reading.quietest == DaySpending(day: CalendarDay(year: 2026, month: 10, day: 12), amount: 95_000))
        #expect(reading.isWeekendHeavy)
        #expect(reading.top.map(\.percent) == [46, 21, 18, 15])
    }

    @Test("more, the same, and only the four largest of five categories, their shares of the whole")
    func comparisons() {
        let more = week([100, 0, 0, 0, 0, 0, 0], previous: 50, categories: [(.food, 100)])
        #expect(WeeklySummaryReading(more).comparison == .more(50))
        #expect(!WeeklySummaryReading(more).isWeekendHeavy)
        let same = week([0, 0, 0, 0, 0, 0, 100], previous: 100, categories: [(.food, 100)])
        #expect(WeeklySummaryReading(same).comparison == .same)
        let five = week(
            [500, 0, 0, 0, 0, 0, 0], previous: 0,
            categories: [(.food, 200), (.transport, 100), (.shopping, 100), (.bills, 50), (.health, 50)])
        #expect(WeeklySummaryReading(five).top.map(\.percent) == [40, 20, 20, 10])
    }

    @Test("an empty week has no busiest or quietest day and no heavy weekend")
    func empty() {
        let reading = WeeklySummaryReading(week([0, 0, 0, 0, 0, 0, 0], previous: 0, categories: []))
        #expect(reading.busiest == nil && reading.quietest == nil && !reading.isWeekendHeavy && reading.top.isEmpty)
    }

    @Test("Saturdays and Sundays, before and after the reference Sunday, are the weekend")
    func weekend() {
        #expect(WeeklySummaryReading.isWeekend(CalendarDay(year: 2026, month: 10, day: 10)))
        #expect(WeeklySummaryReading.isWeekend(CalendarDay(year: 2026, month: 10, day: 4)))
        #expect(WeeklySummaryReading.isWeekend(CalendarDay(year: 2026, month: 10, day: 18)))
        #expect(!WeeklySummaryReading.isWeekend(CalendarDay(year: 2026, month: 10, day: 8)))
        #expect(!WeeklySummaryReading.isWeekend(CalendarDay(year: 2026, month: 9, day: 30)))
    }
}
