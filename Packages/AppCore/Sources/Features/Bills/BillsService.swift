import APIClient
import Domain

/** The list screen's server calls. */
package protocol BillsService: Sendable {
    /** `GET /bills`, schedules ordered by their next due date. */
    func bills() async throws -> [RecurringBill]
}

/** The API problem to show when a bill operation fails. */
func billsProblem(_ error: any Error) -> AppProblem {
    if let problem = error as? AppProblem { return problem }
    return AppProblem()
}
