import APIClient
import Domain

/** The list screen's server calls. */
package protocol BillsService: Sendable {
    /** `GET /bills`, schedules ordered by their next due date. */
    func bills() async throws -> [RecurringBill]
    /** `GET /wallets`, limited to the signed-in person's debt accounts. */
    func debtAccounts() async throws -> [BillDebtAccount]
    /** `POST /bills`, creating an owner-scoped idempotent schedule. */
    func createBill(_ request: BillCreateRequest) async throws -> RecurringBill
}

/** The API problem to show when a bill operation fails. */
func billsProblem(_ error: any Error) -> AppProblem {
    if let problem = error as? AppProblem { return problem }
    return AppProblem()
}
