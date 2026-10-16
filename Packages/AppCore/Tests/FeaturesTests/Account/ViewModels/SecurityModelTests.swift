import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("SecurityModel")
struct SecurityModelTests {
    private func loaded(
        service: FakeAccountService = FakeAccountService(), settings: FakeSecuritySettings = FakeSecuritySettings()
    ) async -> SecurityModel {
        let model = SecurityModel(service: service, settings: settings)
        await model.load()
        return model
    }

    @Test("loads the device's settings and Sembunyikan Saldo from the account")
    func load() async {
        let model = await loaded(service: FakeAccountService(profile: Sample.profile(hidesBalances: true)))
        #expect(
            model.phase.value
                == SecurityPreferences(isPinLockEnabled: true, autoLock: .immediately, obscuresAppSwitcher: true))
        #expect(model.hidesBalances)
    }

    @Test("a failed load shows the problem")
    func loadFails() async {
        let model = await loaded(service: FakeAccountService(profile: nil))
        guard case .failed(let problem) = model.phase else {
            Issue.record("expected failed")
            return
        }
        #expect(problem == Sample.problem)
    }

    @Test("turning the lock off asks for the PIN, and a wrong one keeps it on")
    func disable() async {
        let settings = FakeSecuritySettings()
        let model = await loaded(settings: settings)
        model.setPinLock(false)
        #expect(model.pinPrompt == .verifyToDisable)
        model.pin = "12345"
        #expect(!model.canSubmitPin)
        await model.submitPin()
        #expect(model.pinPrompt == .verifyToDisable)
        model.pin = "999999"
        await model.submitPin()
        #expect(model.pinError == .wrong)
        model.pin = "123456"
        #expect(model.pinError == nil)
        await model.submitPin()
        #expect(model.pinPrompt == nil)
        #expect(model.pin.isEmpty)
        #expect(await settings.storedPin == nil)
        #expect(model.phase.value?.isPinLockEnabled == false)
    }

    @Test("turning the lock on keeps the new PIN")
    func enable() async {
        let settings = FakeSecuritySettings(pin: nil)
        let model = await loaded(settings: settings)
        model.setPinLock(true)
        #expect(model.pinPrompt == .create)
        model.pin = "246810"
        await model.submitPin()
        #expect(await settings.storedPin == "246810")
        #expect(model.phase.value?.isPinLockEnabled == true)
    }

    @Test("Ganti PIN checks the current PIN, then keeps the new one")
    func change() async {
        let settings = FakeSecuritySettings()
        let model = await loaded(settings: settings)
        model.changePin()
        #expect(model.pinPrompt == .verifyToChange)
        model.pin = "000000"
        await model.submitPin()
        #expect(model.pinError == .wrong)
        model.pin = "123456"
        await model.submitPin()
        #expect(model.pinPrompt == .createReplacement)
        #expect(model.pin.isEmpty)
        model.pin = "654321"
        await model.submitPin()
        #expect(await settings.storedPin == "654321")
        #expect(model.pinPrompt == nil)
    }

    @Test("a PIN the device cannot keep says so, and closing changes nothing")
    func notSaved() async {
        let settings = FakeSecuritySettings(pin: nil)
        await settings.set(savingFails: true)
        let model = await loaded(settings: settings)
        model.setPinLock(true)
        model.pin = "246810"
        await model.submitPin()
        #expect(model.pinError == .notSaved)
        model.cancelPin()
        #expect(model.pinPrompt == nil)
        #expect(await settings.storedPin == nil)
    }

    @Test("Kunci Otomatis keeps the choice and closes the sheet")
    func autoLock() async {
        let model = await loaded()
        model.isChoosingAutoLock = true
        await model.setAutoLock(.fiveMinutes)
        #expect(!model.isChoosingAutoLock)
        #expect(model.phase.value?.autoLock == .fiveMinutes)
    }

    @Test("Samarkan di Pengalih Aplikasi is kept on the device")
    func obscure() async {
        let model = await loaded()
        await model.setObscuresAppSwitcher(false)
        #expect(model.phase.value?.obscuresAppSwitcher == false)
    }

    @Test("Sembunyikan Saldo is saved on the account, and put back when refused")
    func hideBalances() async {
        let service = FakeAccountService()
        let model = await loaded(service: service)
        await model.setHidesBalances(true)
        #expect(model.hidesBalances)
        #expect(model.problem == nil)
        await service.set(fails: true)
        await model.setHidesBalances(false)
        #expect(model.hidesBalances)
        #expect(model.problem == Sample.problem)
    }
}
