import APIClient
import Domain

/** The signed-in person's server-calculated Thursday–Wednesday summary. */
package struct LiveWeeklySummaryService: WeeklySummaryService {
    private let api: KiraAPI

    /** Uses the current authenticated API session. */
    package init(api: KiraAPI) { self.api = api }

    package func weeklySummary(weekStart: CalendarDay) async throws -> WeeklySummary {
        try await api.getWeeklySummary(weekStart: weekStart)
    }
}
