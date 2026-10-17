/**
 Tagihan & Cicilan's calls until the regenerated client has `/bills` (12's routes, wave 5): every
 call fails as a lost connection, so the screens show their failure states and never sample data.
 The integrator replaces both with the Live services when the spec lands.
 */
import APIClient
import Domain
import Features

struct UnavailableBillService: BillService {
    func bills() throws -> BillOverview { throw AppProblem.connectionLost }
}

struct UnavailableBillEditorService: BillEditorService {
    func createBill(_: BillDraft) throws -> String { throw AppProblem.connectionLost }
    func updateBill(id _: String, _: BillDraft) throws -> String { throw AppProblem.connectionLost }
    func deleteBill(id _: String) throws { throw AppProblem.connectionLost }
}
