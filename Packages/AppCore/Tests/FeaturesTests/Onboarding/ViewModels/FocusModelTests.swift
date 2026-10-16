import Domain
import Testing

@testable import Features

@MainActor
@Suite("FocusModel")
struct FocusModelTests {
    @Test("Lanjut saves the card chosen, tracking spending by default")
    func submit() async {
        let service = FakeOnboardingService()
        var saved: [Focus] = []
        let model = FocusModel(service: service) { saved.append($0) }
        #expect(model.selection == .trackSpending)
        model.selection = .debtFree
        await model.submit()
        #expect(await service.calls == [.focus(.debtFree)])
        #expect(saved == [.debtFree])
    }

    @Test("Belum Tahu saves the default focus whatever is chosen")
    func skip() async {
        let service = FakeOnboardingService()
        var saved: [Focus] = []
        let model = FocusModel(service: service) { saved.append($0) }
        model.selection = .debtFree
        await model.skip()
        #expect(saved == [.trackSpending])
    }

    @Test("a refusal shows the problem")
    func fails() async {
        let model = FocusModel(service: FakeOnboardingService(failures: 1)) { _ in Issue.record("saved") }
        await model.submit()
        #expect(model.phase == .failed(FakeOnboardingService.problem))
    }
}
