import Domain

/**
 Ringkasan Mingguan's call (`GET /summary/weekly`, UNG-08): the seven days up to today, WIB. It
 throws an `AppProblem` for an answer the API refused, and any other error when the request did not
 arrive.
 */
package protocol WeeklySummaryService: Sendable {
    /** The week up to today. */
    func weeklySummary() async throws -> WeeklySummary
}
