/** The generated weekly summary contract and its API-to-domain mapping. */
import Domain
import Foundation
import Testing

@testable import APIClient

@Suite("WeeklySummaryAPI")
struct WeeklySummaryAPITests {
    @Test("requests a Thursday and maps totals, seven days, categories and the note")
    func mapsSummary() async throws {
        let (api, transport) = KiraAPI.canned(json: summaryJSON)
        let week = CalendarDay(year: 2026, month: 10, day: 8)

        let summary = try await api.getWeeklySummary(weekStart: week)

        #expect(summary.weekStart == week && summary.weekEnd == CalendarDay(year: 2026, month: 10, day: 14))
        #expect(summary.totals == WeeklyTotals(expense: 250_000, income: 100_000, net: -150_000))
        #expect(summary.previousTotals == WeeklyTotals(expense: 300_000, income: 0, net: -300_000))
        #expect(summary.days.count == 7 && summary.days[0].expense == 50_000)
        #expect(summary.topCategories == [WeeklyTopCategory(category: "food", name: "food", amount: 150_000)])
        #expect(summary.note == "Pengeluaran makan turun.")
        #expect(try #require(await transport.request).path == "/api/summaries/weekly?week=2026-10-08")
    }

    @Test("maps an activity-free week with a nil note")
    func mapsEmptyWeek() async throws {
        let (api, _) = KiraAPI.canned(json: emptyJSON)

        let summary = try await api.getWeeklySummary(weekStart: CalendarDay(year: 2026, month: 10, day: 8))

        #expect(summary.isEmpty && summary.note == nil && summary.topCategories.isEmpty)
    }

    @Test("surfaces documented and generic API problems")
    func problems() async {
        await expectProblems([401, 422]) {
            _ = try await $0.getWeeklySummary(weekStart: CalendarDay(year: 2026, month: 10, day: 8))
        }
    }

    @Test("rejects invalid dates returned by the server")
    func invalidDates() async {
        let (periodAPI, _) = KiraAPI.canned(json: summaryJSON.replacingOccurrences(of: "2026-10-08", with: "bad-date"))
        await #expect(throws: AppProblem()) {
            _ = try await periodAPI.getWeeklySummary(weekStart: CalendarDay(year: 2026, month: 10, day: 8))
        }

        let invalidDayJSON = summaryJSON.replacingOccurrences(of: "2026-10-09", with: "bad-date")
        let (dayAPI, _) = KiraAPI.canned(json: invalidDayJSON)
        await #expect(throws: AppProblem()) {
            _ = try await dayAPI.getWeeklySummary(weekStart: CalendarDay(year: 2026, month: 10, day: 8))
        }
    }
}

private let summaryJSON =
    #"{"period":{"from":"2026-10-08","to":"2026-10-14"},"totals":{"expense":250000,"income":100000,"net":-150000},"previous":{"expense":300000,"income":0,"net":-300000},"days":[{"date":"2026-10-08","expense":50000,"income":0},{"date":"2026-10-09","expense":20000,"income":0},{"date":"2026-10-10","expense":30000,"income":100000},{"date":"2026-10-11","expense":40000,"income":0},{"date":"2026-10-12","expense":60000,"income":0},{"date":"2026-10-13","expense":25000,"income":0},{"date":"2026-10-14","expense":25000,"income":0}],"topCategories":[{"category":"food","amount":150000}],"note":"Pengeluaran makan turun."}"#

private let emptyJSON =
    #"{"period":{"from":"2026-10-08","to":"2026-10-14"},"totals":{"expense":0,"income":0,"net":0},"previous":{"expense":50000,"income":0,"net":-50000},"days":[{"date":"2026-10-08","expense":0,"income":0},{"date":"2026-10-09","expense":0,"income":0},{"date":"2026-10-10","expense":0,"income":0},{"date":"2026-10-11","expense":0,"income":0},{"date":"2026-10-12","expense":0,"income":0},{"date":"2026-10-13","expense":0,"income":0},{"date":"2026-10-14","expense":0,"income":0}],"topCategories":[],"note":null}"#
