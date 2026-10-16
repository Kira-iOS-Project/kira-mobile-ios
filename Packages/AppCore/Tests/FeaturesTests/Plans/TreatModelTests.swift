import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("TreatModel")
struct TreatModelTests {
    @Test("totals Kira Plus's monthly price times the months")
    func total() async {
        let model = TreatModel(service: FakePlansService())
        #expect(model.total == 0)
        await model.load()
        #expect(model.months == 3)
        #expect(model.total == 87_000)
        model.months = 6
        #expect(model.total == 174_000)
    }

    @Test("is empty without Kira Plus, and shows the problem when the plans fail")
    func loadStates() async {
        let noPlus = TreatModel(service: FakePlansService(plansResult: .success(PlansFixtures.catalog(plans: []))))
        await noPlus.load()
        guard case .empty = noPlus.phase else {
            Issue.record("expected empty")
            return
        }
        let broken = TreatModel(service: FakePlansService(plansResult: .failure(problem("X"))))
        await broken.load()
        guard case .failed = broken.phase else {
            Issue.record("expected a failure")
            return
        }
    }

    @Test("sends the gift for the picked months, or keeps the problem")
    func sends() async {
        let service = FakePlansService()
        let model = TreatModel(service: service)
        model.months = 1
        await model.send()
        #expect(model.gift?.amount == 87_000)
        #expect(!model.isSending)
        #expect(await service.log.calls == ["treat 1 qris"])

        let refused = TreatModel(service: FakePlansService(treatResult: .failure(problem("VALIDATION_FAILED"))))
        await refused.send()
        #expect(refused.gift == nil)
        #expect(refused.sendProblem?.code == "VALIDATION_FAILED")
    }
}
