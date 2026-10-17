/**
 Tagihan & Cicilan's list until its Live service lands (`GET /bills`, 5e): every load fails as a
 lost connection, so the screen shows its failure state and never sample data.
 */
import APIClient
import Domain
import Features

struct UnavailableBillService: BillService {
    func bills() throws -> BillOverview { throw AppProblem.connectionLost }
}
