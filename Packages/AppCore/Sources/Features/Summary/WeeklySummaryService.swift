import APIClient
import Domain

/** The weekly summary endpoint. */
package protocol WeeklySummaryService: Sendable {
    /** `GET /api/summaries/weekly?week=`, a completed Thursday through Wednesday period. */
    func weeklySummary(weekStart: CalendarDay) async throws -> WeeklySummary
}

/** The API problem to show when a summary request fails. */
func weeklySummaryProblem(_ error: any Error) -> AppProblem {
    if let problem = error as? AppProblem { return problem }
    return AppProblem()
}
