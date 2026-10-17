import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LiveWeeklySummaryService")
struct LiveWeeklySummaryServiceTests {
    private func reply(start: String = "2026-10-08") -> RoutedTransport.Reply {
        ok(
            #"""
            {"start":"\#(start)","end":"2026-10-14","total":950000,"previousTotal":1000000,\#
            "days":[{"date":"2026-10-08","expense":640000},{"date":"2026-10-09","expense":310000}],\#
            "categories":[{"category":"food","amount":640000},{"category":"transport","amount":310000}],\#
            "budget":null}
            """#)
    }

    @Test("GET /summary/weekly becomes the week, each day a WIB day and each category the app's")
    func week() async throws {
        let (api, transport) = KiraAPI.routed(["GET /api/summary/weekly": reply()])
        let week = try await LiveWeeklySummaryService(api: api).weeklySummary()
        #expect(week.start == CalendarDay(year: 2026, month: 10, day: 8) && week.end.day == 14)
        #expect(week.total == 950_000 && week.previousTotal == 1_000_000)
        #expect(
            week.days == [
                DaySpending(day: CalendarDay(year: 2026, month: 10, day: 8), amount: 640_000),
                DaySpending(day: CalendarDay(year: 2026, month: 10, day: 9), amount: 310_000),
            ])
        #expect(week.categories.map(\.category) == [.food, .transport])
        #expect(await transport.routes == ["GET /api/summary/weekly"])
    }

    @Test("a day it cannot read, every problem by its code, and a lost connection as such")
    func failures() async {
        let (bad, _) = KiraAPI.routed(["GET /api/summary/weekly": reply(start: "2026-13-40")])
        await #expect(throws: AppProblem.self) { try await LiveWeeklySummaryService(api: bad).weeklySummary() }
        for (code, status) in [("AUTH_UNAUTHENTICATED", 401), ("VALIDATION_FAILED", 422), ("INTERNAL_ERROR", 500)] {
            let (api, _) = KiraAPI.routed(["GET /api/summary/weekly": problem(code, status: status)])
            do {
                _ = try await LiveWeeklySummaryService(api: api).weeklySummary()
                Issue.record("\(code) returned")
            } catch {
                #expect((error as? AppProblem)?.code == code)
            }
        }
        do {
            _ = try await LiveWeeklySummaryService(api: .offline).weeklySummary()
            Issue.record("offline returned")
        } catch {
            #expect(AppProblem(error).isConnectionLoss)
        }
    }
}
