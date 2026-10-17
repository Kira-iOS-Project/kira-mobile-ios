import Domain

/** UNG-03 Detail Utang's call; it throws an `AppProblem` when the API refuses it (404 for a debt gone). */
package protocol DebtDetailService: Sendable {
    /** `GET /debts/{id}` (`getDebt`). */
    func debt(id: String) async throws -> DebtDetail
}
