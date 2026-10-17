import APIClient
import Testing

@testable import Features

@MainActor
@Suite("PinSetupModel")
struct PinSetupModelTests {
    @Test("a repeated digit is refused until the PIN changes, and nothing is kept")
    func weak() async {
        let store = FakePinSetup()
        let model = PinSetupModel(service: FakeOnboardingService(), pinSetup: store) {}
        model.pin = "11111"
        await model.createPin()
        #expect(!model.showsWeakPin)
        model.pin = "111111"
        await model.createPin()
        #expect(model.showsWeakPin)
        #expect(await store.saved.isEmpty)
        model.pin = "111111"
        #expect(model.showsWeakPin)
        model.pin = "48192"
        #expect(!model.showsWeakPin)
        model.pin = "123456"
        await model.createPin()
        model.weakPinClosed()
        #expect(!model.showsWeakPin && model.pin.isEmpty)
    }

    @Test("Buat PIN saves the balance choice and the PIN, shows the dialog, and Mulai finishes")
    func create() async {
        let service = FakeOnboardingService()
        let store = FakePinSetup()
        var finished = false
        let model = PinSetupModel(service: service, pinSetup: store) { finished = true }
        model.pin = "481923"
        model.hidesBalances = true
        await model.createPin()
        #expect(await service.calls == [.hideBalances(true)])
        #expect(await store.saved == ["481923"])
        #expect(model.showsSuccess && !finished)
        model.start()
        #expect(finished)
    }

    @Test("Nanti Saja goes on without a PIN, saving nothing when balances stay shown")
    func skip() async {
        let service = FakeOnboardingService()
        let store = FakePinSetup()
        var finished = false
        let model = PinSetupModel(service: service, pinSetup: store) { finished = true }
        await model.skip()
        #expect(finished)
        #expect(await service.calls.isEmpty)
        #expect(await store.saved.isEmpty)
    }

    @Test("a failure to keep the PIN or save the choice stays on the screen")
    func fails() async {
        let model = PinSetupModel(service: FakeOnboardingService(), pinSetup: FakePinSetup(fails: true)) {
            Issue.record("finished")
        }
        model.pin = "481923"
        await model.createPin()
        #expect(model.phase == .failed(AppProblem()))
        #expect(!model.showsSuccess)
        let refused = PinSetupModel(service: FakeOnboardingService(failures: 1), pinSetup: FakePinSetup()) {
            Issue.record("finished")
        }
        refused.hidesBalances = true
        await refused.skip()
        #expect(refused.phase == .failed(FakeOnboardingService.problem))
    }
}
