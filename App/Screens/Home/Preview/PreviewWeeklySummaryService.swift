/**
 Ringkasan Mingguan on the board's week (RingkasanMingguan): 8 to 14 October 2026, Rp1.385.000,00
 spent, Rp120.000,00 less than the week before, Sabtu the busiest.
 */
import Domain
import Features

nonisolated extension WeeklySummary {
    /** The board's week. */
    static let sample: WeeklySummary = {
        let start = CalendarDay(year: 2026, month: 10, day: 8)
        let amounts = [165_000, 240_000, 310_000, 280_000, 95_000, 140_000, 155_000]
        return WeeklySummary(
            start: start, end: start.adding(days: 6), total: 1_385_000, previousTotal: 1_505_000,
            days: amounts.enumerated().map { DaySpending(day: start.adding(days: $0), amount: $1) },
            categories: [
                CategorySpending(category: .food, amount: 640_000),
                CategorySpending(category: .transport, amount: 285_000),
                CategorySpending(category: .shopping, amount: 250_000),
                CategorySpending(category: .entertainment, amount: 210_000),
            ])
    }()
}

nonisolated struct PreviewWeeklySummaryService: WeeklySummaryService {
    func weeklySummary() -> WeeklySummary { .sample }
}
