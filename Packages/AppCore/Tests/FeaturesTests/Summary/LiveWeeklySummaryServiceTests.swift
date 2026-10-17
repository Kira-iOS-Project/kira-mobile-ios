/** LiveWeeklySummaryService forwards the requested week and reads deterministic server values. */
import APIClient
import Domain
import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@testable import Features

@Suite("LiveWeeklySummaryService")
struct LiveWeeklySummaryServiceTests {
    @Test("maps the week and forwards its Thursday start date")
    func mapsSummary() async throws {
        let transport = WeeklySummaryTransport(json: summaryJSON)
        let api = KiraAPI(serverURL: URL(string: "https://api.test") ?? URL(filePath: "/"), transport: transport)
        let start = CalendarDay(year: 2026, month: 10, day: 8)

        let summary = try await LiveWeeklySummaryService(api: api).weeklySummary(weekStart: start)

        #expect(summary.weekStart == start && summary.weekEnd == CalendarDay(year: 2026, month: 10, day: 14))
        #expect(summary.totals == WeeklyTotals(expense: 250_000, income: 100_000, net: -150_000))
        #expect(summary.previousTotals == WeeklyTotals(expense: 300_000, income: 0, net: -300_000))
        #expect(summary.days.count == 7 && summary.days[0].expense == 50_000)
        #expect(summary.topCategories == [WeeklyTopCategory(category: "food", name: "food", amount: 150_000)])
        #expect(summary.note == "Pengeluaran makan turun.")
        #expect(await transport.requestPath == "/api/summaries/weekly?week=2026-10-08")
    }

    @Test("keeps an empty week's note nil")
    func keepsEmptyNoteNil() async throws {
        let transport = WeeklySummaryTransport(json: emptySummaryJSON)
        let api = KiraAPI(serverURL: URL(string: "https://api.test") ?? URL(filePath: "/"), transport: transport)
        let week = CalendarDay(year: 2026, month: 10, day: 8)

        let summary = try await LiveWeeklySummaryService(api: api).weeklySummary(weekStart: week)

        #expect(summary.isEmpty && summary.note == nil)
        #expect(summary.days.count == 7 && summary.topCategories.isEmpty)
        #expect(await transport.requestPath == "/api/summaries/weekly?week=2026-10-08")
    }
}

private actor WeeklySummaryTransport: ClientTransport {
    private let json: String
    private(set) var requestPath: String?

    init(json: String) { self.json = json }

    func send(
        _ request: HTTPRequest, body _: HTTPBody?, baseURL _: URL, operationID _: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        requestPath = request.path
        var fields = HTTPFields()
        fields[.contentType] = "application/json"
        return (HTTPResponse(status: .init(code: 200), headerFields: fields), HTTPBody(Data(json.utf8)))
    }
}

private let summaryJSON =
    #"{"period":{"from":"2026-10-08","to":"2026-10-14"},"totals":{"expense":250000,"income":100000,"net":-150000},"previous":{"expense":300000,"income":0,"net":-300000},"days":[{"date":"2026-10-08","expense":50000,"income":0},{"date":"2026-10-09","expense":20000,"income":0},{"date":"2026-10-10","expense":30000,"income":100000},{"date":"2026-10-11","expense":40000,"income":0},{"date":"2026-10-12","expense":60000,"income":0},{"date":"2026-10-13","expense":25000,"income":0},{"date":"2026-10-14","expense":25000,"income":0}],"topCategories":[{"category":"food","amount":150000}],"note":"Pengeluaran makan turun."}"#

private let emptySummaryJSON =
    #"{"period":{"from":"2026-10-08","to":"2026-10-14"},"totals":{"expense":0,"income":0,"net":0},"previous":{"expense":50000,"income":0,"net":-50000},"days":[{"date":"2026-10-08","expense":0,"income":0},{"date":"2026-10-09","expense":0,"income":0},{"date":"2026-10-10","expense":0,"income":0},{"date":"2026-10-11","expense":0,"income":0},{"date":"2026-10-12","expense":0,"income":0},{"date":"2026-10-13","expense":0,"income":0},{"date":"2026-10-14","expense":0,"income":0}],"topCategories":[],"note":null}"#
