import Domain
import Testing

@testable import Features

@MainActor
@Suite("ConsentModel")
struct ConsentModelTests {
    @Test("both purposes start on and save as chosen, then move on")
    func saves() async {
        let service = FakeOnboardingService()
        var saved = false
        let model = ConsentModel(service: service) { saved = true }
        #expect(model.aiProcessing && model.weeklySummary)
        model.aiProcessing = false
        await model.submit()
        #expect(await service.calls == [.consents(ConsentChoices(aiProcessing: false, weeklySummary: true))])
        #expect(saved)
        #expect(model.phase == .editing)
    }

    @Test("a refusal stays on the screen with the problem")
    func fails() async {
        let model = ConsentModel(service: FakeOnboardingService(failures: 1)) { Issue.record("moved on") }
        await model.submit()
        #expect(model.phase == .failed(FakeOnboardingService.problem))
    }
}
