import Domain
import Features

/** Sample data for previews and the debug accessibility launcher. */
nonisolated struct PreviewWeeklySummaryService: WeeklySummaryService {
    func weeklySummary(weekStart: CalendarDay) async throws -> WeeklySummary {
        WeeklySummary(
            weekStart: weekStart,
            totals: WeeklyTotals(expense: 1_385_000, income: 7_500_000, net: 6_115_000),
            previousTotals: WeeklyTotals(expense: 1_200_000, income: 6_900_000, net: 5_700_000),
            days: (0..<7).map { index in
                WeeklySummaryDay(
                    date: weekStart.adding(days: index),
                    expense: [120_000, 240_000, 75_000, 330_000, 210_000, 180_000, 230_000][index],
                    income: index == 0 ? 7_500_000 : 0)
            },
            topCategories: [
                WeeklyTopCategory(category: "bills", name: "Tagihan", amount: 550_000),
                WeeklyTopCategory(category: "food", name: "Makanan", amount: 420_000),
                WeeklyTopCategory(category: "transport", name: "Transportasi", amount: 280_000),
                WeeklyTopCategory(category: "shopping", name: "Belanja", amount: 135_000),
            ], note: "Pengeluaran terbesar minggu ini ada di Tagihan.")
    }
}
