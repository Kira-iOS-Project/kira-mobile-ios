import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("InvoicesModel")
struct InvoicesModelTests {
    @Test("loads the invoices, empty when there are none, or the problem")
    func loads() async {
        let model = InvoicesModel(service: FakePlansService())
        await model.load()
        #expect(model.phase.value == [PlansFixtures.invoice])

        let none = InvoicesModel(service: FakePlansService(invoicesResult: .success([])))
        await none.load()
        guard case .empty = none.phase else {
            Issue.record("expected empty")
            return
        }

        let broken = InvoicesModel(service: FakePlansService(invoicesResult: .failure(problem("X"))))
        await broken.load()
        guard case .failed = broken.phase else {
            Issue.record("expected a failure")
            return
        }
    }
}
