import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("PlansModel")
struct PlansModelTests {
    @Test("loads the catalog and starts on the period it was given")
    func loads() async {
        let model = PlansModel(service: FakePlansService(), period: .yearly)
        #expect(model.phase.value == nil)
        await model.load()
        #expect(model.phase.value == PlansFixtures.catalog())
        #expect(model.period == .yearly)
        #expect(PlansModel(service: FakePlansService()).period == .monthly)
    }

    @Test("shows the problem when the plans do not load")
    func fails() async {
        let model = PlansModel(service: FakePlansService(plansResult: .failure(problem("INTERNAL_ERROR"))))
        await model.load()
        guard case .failed(let failure) = model.phase else {
            Issue.record("expected a failure")
            return
        }
        #expect(failure.code == "INTERNAL_ERROR")
    }
}
