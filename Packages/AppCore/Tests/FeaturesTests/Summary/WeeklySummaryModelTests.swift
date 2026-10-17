import APIClient
import Domain
import Testing

@testable import Features

struct FakeWeeklySummaryService: WeeklySummaryService {
    let result: Result<WeeklySummary, AppProblem>

    func weeklySummary(weekStart: CalendarDay) async throws -> WeeklySummary {
        try result.get()
    }
}

@MainActor
@Suite("WeeklySummaryModel")
struct WeeklySummaryModelTests {
    @Test("loads the latest completed week and its totals")
    func loaded() async throws {
        let start = CalendarDay(year: 2026, month: 10, day: 8)
        let summary = WeeklySummary(
            weekStart: start, totals: WeeklyTotals(expense: 1_385_000, income: 0, net: -1_385_000),
            previousTotals: WeeklyTotals(expense: 1_200_000, income: 0, net: -1_200_000),
            days: [], topCategories: [], note: "Pengeluaran terbesar ada di Rumah.")
        let model = WeeklySummaryModel(
            service: FakeWeeklySummaryService(result: .success(summary)),
            today: { CalendarDay(year: 2026, month: 10, day: 17) })
        await model.load()
        #expect(try #require(model.phase.value) == summary)
        await model.load()
        #expect(try #require(model.phase.value) == summary)
    }

    @Test("labels the seven bars Thursday through Wednesday and highlights the largest day")
    func chart() async {
        let start = CalendarDay(year: 2026, month: 10, day: 8)
        let days = (0..<7).map { offset in
            WeeklySummaryDay(
                date: start.adding(days: offset), expense: [10, 20, 30, 40, 50, 60, 50][offset], income: 0)
        }
        let summary = WeeklySummary(
            weekStart: start, totals: WeeklyTotals(expense: 260, income: 0, net: -260),
            previousTotals: WeeklyTotals(expense: 0, income: 0, net: 0), days: days, topCategories: [], note: nil)
        let model = WeeklySummaryModel(
            service: FakeWeeklySummaryService(result: .success(summary)),
            today: { CalendarDay(year: 2026, month: 10, day: 17) })
        await model.load()
        #expect(
            model.chartDays.map(\.weekday) == [.thursday, .friday, .saturday, .sunday, .monday, .tuesday, .wednesday])
        #expect(model.chartDays.map(\.expense) == [10, 20, 30, 40, 50, 60, 50])
        #expect(model.chartDays.map(\.id) == Array(0..<7))
        #expect(model.chartDays(wibOffset: Int.max) == model.chartDays)
        #expect(model.highlightedChartIndex == 5)
    }

    @Test("an empty week has no note and uses the empty state")
    func empty() async {
        let summary = WeeklySummary(
            weekStart: CalendarDay(year: 2026, month: 10, day: 8), totals: WeeklyTotals(expense: 0, income: 0, net: 0),
            previousTotals: WeeklyTotals(expense: 0, income: 0, net: 0), days: [], topCategories: [], note: nil)
        let model = WeeklySummaryModel(
            service: FakeWeeklySummaryService(result: .success(summary)),
            today: { CalendarDay(year: 2026, month: 10, day: 17) })
        await model.load()
        guard case .empty = model.phase else {
            Issue.record("expected empty")
            return
        }
        #expect(model.chartDays.isEmpty)
        #expect(model.highlightedChartIndex == nil)
    }

    @Test("uses the default WIB day provider when one is not injected")
    func defaultToday() async {
        let summary = WeeklySummary(
            weekStart: CalendarDay(year: 2026, month: 10, day: 8), totals: WeeklyTotals(expense: 1, income: 0, net: -1),
            previousTotals: WeeklyTotals(expense: 0, income: 0, net: 0), days: [], topCategories: [], note: nil)
        let model = WeeklySummaryModel(service: FakeWeeklySummaryService(result: .success(summary)))
        await model.load()
        #expect(model.phase.value == summary)
    }

    @Test("preserves a known API problem and falls back for another error")
    func failure() async {
        let known = AppProblem(code: "INTERNAL_ERROR", requestId: "weekly-req")
        let model = WeeklySummaryModel(
            service: FakeWeeklySummaryService(result: .failure(known)),
            today: { CalendarDay(year: 2026, month: 10, day: 17) })
        await model.load()
        guard case .failed(let problem) = model.phase else {
            Issue.record("expected failure")
            return
        }
        #expect(problem == known)
        struct Offline: Error {}
        #expect(weeklySummaryProblem(Offline()) == AppProblem())
        #expect(weeklySummaryProblem(known) == known)
    }
}
