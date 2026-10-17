import Domain

/**
 Tagihan & Cicilan's calls (UNG-06, UNG-07). Every call throws an `AppProblem` when the API refuses
 it or the network is down.
 */
package protocol BillService: Sendable {
    /** `GET /bills` (`listBills`): the recurring bills, grouped, with their monthly total. */
    func bills() async throws -> BillOverview
}
