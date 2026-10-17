import Domain
import Testing

@Suite("WeeklySummary")
struct WeeklySummaryTests {
    @Test("sets a seven-day period and detects an empty week by its totals")
    func periodAndEmpty() {
        let start = CalendarDay(year: 2026, month: 10, day: 8)
        let empty = WeeklySummary(
            weekStart: start, totals: WeeklyTotals(expense: 0, income: 0, net: 0),
            previousTotals: WeeklyTotals(expense: 100, income: 20, net: -80), days: [], topCategories: [], note: nil)
        #expect(empty.weekEnd == CalendarDay(year: 2026, month: 10, day: 14))
        #expect(empty.isEmpty)
        #expect(empty.note == nil)
        #expect(empty.expenseDifference == 100)
        #expect(!empty.spendingIncreased)
        #expect(!empty.spendingUnchanged)
    }

    @Test("a transaction total makes the summary nonempty")
    func activity() {
        let day = CalendarDay(year: 2026, month: 10, day: 8)
        let summary = WeeklySummary(
            weekStart: day, totals: WeeklyTotals(expense: 0, income: 10, net: 10),
            previousTotals: WeeklyTotals(expense: 0, income: 0, net: 0),
            days: [WeeklySummaryDay(date: day, expense: 0, income: 10)],
            topCategories: [WeeklyTopCategory(category: "salary", name: "Gaji", amount: 10)], note: "Ada pemasukan.")
        #expect(!summary.isEmpty)
        #expect(summary.days.first?.id == day)
        #expect(summary.topCategories.first?.id == "salary")
        #expect(summary.expenseDifference == 0)
        #expect(summary.spendingUnchanged)
        #expect(!summary.spendingIncreased)
    }

    @Test("compares this week's spending with the previous week")
    func spendingComparison() {
        let week = CalendarDay(year: 2026, month: 10, day: 8)
        let summary = WeeklySummary(
            weekStart: week, totals: WeeklyTotals(expense: 300, income: 0, net: -300),
            previousTotals: WeeklyTotals(expense: 100, income: 0, net: -100), days: [], topCategories: [], note: nil)
        #expect(summary.expenseDifference == 200)
        #expect(summary.spendingIncreased)
        #expect(!summary.spendingUnchanged)
    }

    @Test("selects the latest completed Thursday-to-Wednesday period")
    func latestCompletedWeek() {
        #expect(
            WeeklySummary.latestCompletedWeekStart(on: CalendarDay(year: 2026, month: 10, day: 17))
                == CalendarDay(year: 2026, month: 10, day: 8))
        #expect(
            WeeklySummary.latestCompletedWeekStart(on: CalendarDay(year: 2026, month: 10, day: 21))
                == CalendarDay(year: 2026, month: 10, day: 8))
        #expect(
            WeeklySummary.latestCompletedWeekStart(on: CalendarDay(year: 2025, month: 1, day: 2))
                == CalendarDay(year: 2024, month: 12, day: 26))
        #expect(
            WeeklySummary.latestCompletedWeekStart(
                on: CalendarDay(year: 2026, month: 10, day: 17), wibOffset: Int.max)
                == CalendarDay(year: 2026, month: 10, day: 8))
    }
}
