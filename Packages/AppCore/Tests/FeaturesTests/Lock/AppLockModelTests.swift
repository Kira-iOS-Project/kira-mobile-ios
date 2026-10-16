import Domain
import Foundation
import Testing

@testable import Features

@MainActor
private func lockModel(
    pin: String? = "381449", vault: InMemoryVault = InMemoryVault(), clock: TestClock = TestClock()
) throws -> AppLockModel {
    let pins = PinStore(vault: vault, now: clock.now)
    if let pin { try pins.setPin(pin) }
    return AppLockModel(pins: pins, vault: vault, now: clock.now)
}

@MainActor
@Suite("AppLockModel")
struct AppLockModelTests {
    @Test("locks at launch only with a PIN")
    func launch() throws {
        let locked = try lockModel()
        locked.launch()
        #expect(locked.isLocked)
        let open = try lockModel(pin: nil)
        open.launch()
        #expect(!open.isLocked)
        #expect(!open.hasPin)
    }

    @Test("opens with the right PIN only")
    func unlock() throws {
        let lock = try lockModel()
        lock.launch()
        #expect(lock.unlock(with: "000001") == .wrong(remainingAttempts: 4))
        #expect(lock.isLocked)
        #expect(lock.pausedUntil() == nil)
        #expect(lock.unlock(with: "381449") == .correct)
        #expect(!lock.isLocked)
    }

    @Test("blurs in the app switcher when the setting is on")
    func obscures() throws {
        let lock = try lockModel()
        lock.scenePresenceChanged(to: .inactive)
        #expect(lock.isObscured)
        lock.scenePresenceChanged(to: .active)
        #expect(!lock.isObscured)
        lock.update { $0.obscuresInAppSwitcher = false }
        lock.scenePresenceChanged(to: .background)
        #expect(!lock.isObscured)
    }

    @Test("locks on return once the auto-lock interval has passed", arguments: AutoLock.allCases)
    func autoLock(setting: AutoLock) throws {
        let clock = TestClock()
        let lock = try lockModel(clock: clock)
        lock.update { $0.autoLock = setting }
        lock.scenePresenceChanged(to: .background)
        clock.advance(max(setting.interval - 1, 0))
        lock.scenePresenceChanged(to: .background)
        lock.scenePresenceChanged(to: .active)
        #expect(lock.isLocked == (setting == .immediately))
        lock.scenePresenceChanged(to: .background)
        clock.advance(setting.interval)
        lock.scenePresenceChanged(to: .active)
        #expect(lock.isLocked)
    }

    @Test("never locks without a PIN, nor on a return without a background")
    func noLock() throws {
        let lock = try lockModel(pin: nil)
        lock.scenePresenceChanged(to: .active)
        lock.scenePresenceChanged(to: .background)
        lock.scenePresenceChanged(to: .active)
        #expect(!lock.isLocked)
    }

    @Test("a new PIN replaces the old and opens Kira; a weak one is refused")
    func setPin() throws {
        let lock = try lockModel(pin: nil)
        #expect(throws: PinProblem.tooSimple) { try lock.setPin("123456") }
        try lock.setPin("902716")
        #expect(lock.hasPin)
        #expect(!lock.isLocked)
        #expect(lock.unlock(with: "902716") == .correct)
    }

    @Test("turning the PIN off asks for it first")
    func removePin() throws {
        let lock = try lockModel()
        #expect(lock.removePin(confirmingWith: "000001") == .wrong(remainingAttempts: 4))
        #expect(lock.hasPin)
        #expect(lock.removePin(confirmingWith: "381449") == .correct)
        #expect(!lock.hasPin)
    }

    @Test("hides balances on each open when the setting is on, until the eye is tapped")
    func balances() throws {
        let vault = InMemoryVault()
        let lock = try lockModel(vault: vault)
        #expect(!lock.balancesHidden)
        lock.update { $0.hidesBalancesOnOpen = true }
        lock.launch()
        #expect(lock.balancesHidden)
        lock.toggleBalances()
        #expect(!lock.balancesHidden)
        let reopened = AppLockModel(pins: PinStore(vault: vault), vault: vault)
        #expect(reopened.settings.hidesBalancesOnOpen)
        #expect(reopened.balancesHidden)
        reopened.scenePresenceChanged(to: .background)
        reopened.scenePresenceChanged(to: .active)
        #expect(reopened.isLocked)
    }

    @Test("signing out removes the PIN and the settings")
    func reset() throws {
        let vault = InMemoryVault()
        let lock = try lockModel(vault: vault)
        lock.update { $0.autoLock = .fiveMinutes }
        lock.launch()
        lock.reset()
        #expect(!lock.hasPin)
        #expect(!lock.isLocked)
        #expect(lock.settings == LockSettings())
        #expect(vault.data(for: .lockSettings) == nil)
    }
}
