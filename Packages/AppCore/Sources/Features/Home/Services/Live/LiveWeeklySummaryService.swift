import APIClient
import Domain

/** Ringkasan Mingguan's call over the API client. */
package struct LiveWeeklySummaryService: WeeklySummaryService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /summary/weekly`; a day it cannot read fails the load as the generic problem. */
    package func weeklySummary() async throws -> WeeklySummary {
        let dto = try await api.getWeeklySummary()
        return WeeklySummary(
            start: try Bridge.day(dto.start), end: try Bridge.day(dto.end), total: dto.total,
            previousTotal: dto.previousTotal,
            days: try dto.days.map { DaySpending(day: try Bridge.day($0.date), amount: $0.expense) },
            categories: dto.categories.map { CategorySpending(category: $0.category, amount: $0.amount) })
    }
}
