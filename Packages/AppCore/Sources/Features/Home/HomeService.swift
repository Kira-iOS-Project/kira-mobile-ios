import Domain

/**
 What Beranda needs from the API: `GET /home`, and `PATCH /me {hideBalances}` when the eye is
 tapped. The integrator implements it with the generated client; each call throws an `AppProblem`.
 */
package protocol HomeService: Sendable {
    /** Beranda's content for today. */
    func home() async throws -> HomeOverview

    /** The bills card on Beranda, ordered by the model for the nearest unpaid schedule. */
    func bills() async throws -> [RecurringBill]

    /** Remembers whether amounts are hidden. */
    func setHideBalances(_ isHidden: Bool) async throws
}
