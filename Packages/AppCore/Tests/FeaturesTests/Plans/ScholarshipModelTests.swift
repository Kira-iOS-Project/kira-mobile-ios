import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("ScholarshipModel")
struct ScholarshipModelTests {
    @Test("loads the overview, or the problem")
    func loads() async {
        let model = ScholarshipModel(service: FakePlansService())
        await model.load()
        #expect(model.phase.value == PlansFixtures.overview())

        let broken = ScholarshipModel(service: FakePlansService(scholarshipResult: .failure(problem("X"))))
        await broken.load()
        guard case .failed = broken.phase else {
            Issue.record("expected a failure")
            return
        }
    }

    @Test("withdraws, then reloads the overview")
    func withdraws() async {
        let service = FakePlansService()
        let model = ScholarshipModel(service: service)
        await model.withdraw()
        #expect(!model.isWithdrawing)
        #expect(model.phase.value?.stage == .intro)
        #expect(await service.log.calls == ["withdraw", "scholarship"])
    }

    @Test("keeps the problem of a refused withdrawal")
    func withdrawRefused() async {
        let service = FakePlansService(withdrawResult: .failure(problem("SCHOLARSHIP_APPLICATION_NOT_FOUND")))
        let model = ScholarshipModel(service: service)
        await model.withdraw()
        #expect(model.withdrawProblem?.code == "SCHOLARSHIP_APPLICATION_NOT_FOUND")
    }
}
