import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("ProfileModel")
struct ProfileModelTests {
    @Test("loads the account and whether the PIN lock is on")
    func load() async {
        let model = ProfileModel(service: FakeAccountService(), settings: FakeSecuritySettings(), onSignedOut: {})
        #expect(model.phase.value == nil)
        await model.load()
        #expect(model.phase.value == Sample.profile())
        #expect(model.isPinLockEnabled)
    }

    @Test("a first load that fails shows the problem")
    func loadFails() async {
        let model = ProfileModel(
            service: FakeAccountService(profile: nil), settings: FakeSecuritySettings(pin: nil), onSignedOut: {})
        await model.load()
        guard case .failed(let problem) = model.phase else {
            Issue.record("expected failed")
            return
        }
        #expect(problem == Sample.problem)
        #expect(!model.isPinLockEnabled)
    }

    @Test("a reload that fails keeps the account shown")
    func reloadFails() async {
        let service = FakeAccountService()
        let model = ProfileModel(service: service, settings: FakeSecuritySettings(), onSignedOut: {})
        await model.load()
        await service.set(profile: nil)
        await model.load()
        #expect(model.phase.value == Sample.profile())
    }

    @Test("Keluar asks, then signs out, clears the device and leaves", arguments: [false, true])
    func signOut(serverFails: Bool) async {
        let service = FakeAccountService()
        await service.set(fails: serverFails)
        let settings = FakeSecuritySettings()
        let counter = CallCounter()
        let model = ProfileModel(service: service, settings: settings, onSignedOut: counter.call)
        model.askToSignOut()
        #expect(model.isConfirmingSignOut)
        await model.signOut()
        #expect(await service.calls == ["signOut"])
        #expect(await settings.cleared)
        #expect(!model.isConfirmingSignOut)
        #expect(!model.isSigningOut)
        #expect(counter.count == 1)
    }
}
