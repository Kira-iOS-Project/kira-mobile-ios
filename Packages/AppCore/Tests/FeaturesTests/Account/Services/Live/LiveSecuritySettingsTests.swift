import Domain
import Testing

@testable import Features

@MainActor
@Suite("LiveSecuritySettings")
struct LiveSecuritySettingsTests {
    private let vault = InMemoryVault()

    private func settings() -> (LiveSecuritySettings, AppLockModel) {
        let pins = PinStore(vault: vault)
        let lock = AppLockModel(pins: pins, vault: vault)
        return (LiveSecuritySettings(lock: lock, pins: pins), lock)
    }

    @Test("starts without a PIN, locking at once and blurred in the app switcher")
    func defaults() async {
        let (settings, _) = settings()
        #expect(
            await settings.preferences()
                == SecurityPreferences(
                    isPinLockEnabled: false, autoLock: .immediately, obscuresAppSwitcher: true))
    }

    @Test("a PIN set turns the lock on, checks right and wrong, and turning it off forgets it")
    func pin() async throws {
        let (settings, lock) = settings()
        try await settings.setPin("481923")
        #expect(lock.hasPin && !lock.isLocked)
        #expect(settings.verifyPin("481923"))
        #expect(!settings.verifyPin("000000"))
        await settings.disablePinLock()
        #expect(!lock.hasPin)
        #expect(await !settings.preferences().isPinLockEnabled)
    }

    @Test("a PIN PinPolicy refuses is thrown and nothing is kept")
    func simplePin() async {
        let (settings, lock) = settings()
        await #expect(throws: PinProblem.tooSimple) { try await settings.setPin("123456") }
        #expect(!lock.hasPin)
    }

    @Test("Kunci Otomatis and the blur are kept in the lock's settings", arguments: AutoLockDelay.allCases)
    func autoLock(delay: AutoLockDelay) async {
        let (settings, lock) = settings()
        await settings.setAutoLock(delay)
        await settings.setObscuresAppSwitcher(false)
        #expect(
            await settings.preferences()
                == SecurityPreferences(
                    isPinLockEnabled: false, autoLock: delay, obscuresAppSwitcher: false))
        #expect(AutoLockDelay(lock.settings.autoLock) == delay)
    }

    @Test("clearing local data forgets the PIN and the settings")
    func clear() async throws {
        let (settings, lock) = settings()
        try await settings.setPin("481923")
        await settings.setAutoLock(.fiveMinutes)
        await settings.clearLocalData()
        #expect(!lock.hasPin && lock.settings == LockSettings())
    }

    @Test("onboarding's PIN goes through the lock, with the same policy")
    func pinSetup() async throws {
        let (_, lock) = settings()
        let setup = LockPinSetup(lock: lock)
        try await setup.save(pin: "481923")
        #expect(lock.hasPin)
        await #expect(throws: PinProblem.tooSimple) { try await setup.save(pin: "121212") }
    }
}
