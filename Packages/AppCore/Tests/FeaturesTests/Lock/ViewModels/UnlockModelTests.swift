import Foundation
import Testing

@testable import Features

@MainActor
private func unlockModel(clock: TestClock = TestClock(), email: String? = "dinda@email.com") throws -> (
    UnlockModel, AppLockModel
) {
    let vault = InMemoryVault()
    let pins = PinStore(vault: vault, now: clock.now)
    try pins.setPin("381449")
    let lock = AppLockModel(pins: pins, vault: vault, now: clock.now)
    lock.launch()
    return (UnlockModel(lock: lock, email: email, now: clock.now), lock)
}

@MainActor
private func type(_ pin: String, into model: UnlockModel) {
    pin.compactMap(\.wholeNumberValue).forEach(model.enter)
}

@MainActor
@Suite("UnlockModel")
struct UnlockModelTests {
    @Test("greets by the email's name")
    func greeting() throws {
        #expect(try unlockModel().0.displayName == "Dinda")
        #expect(try unlockModel(email: nil).0.displayName == nil)
    }

    @Test("fills a dot per digit, at most six, and deletes the last")
    func digits() throws {
        let (model, _) = try unlockModel()
        model.deleteLast()
        model.enter(10)
        type("38144", into: model)
        #expect(model.filledCount == 5)
        #expect(!model.isComplete)
        model.open()
        #expect(model.filledCount == 5)
        type("97", into: model)
        #expect(model.filledCount == 6)
        #expect(model.isComplete)
        model.deleteLast()
        #expect(model.filledCount == 5)
    }

    @Test("the right PIN opens Kira")
    func opens() throws {
        let (model, lock) = try unlockModel()
        type("381449", into: model)
        model.open()
        #expect(!lock.isLocked)
        #expect(model.phase == .entering)
        #expect(model.filledCount == 0)
    }

    @Test("a wrong PIN clears the dots and says the tries left; the fifth pauses")
    func wrong() throws {
        let clock = TestClock()
        let (model, lock) = try unlockModel(clock: clock)
        type("000001", into: model)
        model.open()
        #expect(model.phase == .wrong(remainingAttempts: 4))
        #expect(model.filledCount == 0)
        for _ in 1...4 {
            type("000001", into: model)
            model.open()
        }
        let until = clock.now().addingTimeInterval(30)
        #expect(model.phase == .paused(until: until))
        #expect(model.secondsLeft(at: clock.now().addingTimeInterval(0.5)) == 30)
        model.enter(1)
        #expect(model.filledCount == 0)
        #expect(UnlockModel(lock: lock, email: nil, now: clock.now).phase == .paused(until: until))
        clock.advance(30)
        model.refreshPause()
        #expect(model.phase == .entering)
        #expect(model.secondsLeft(at: clock.now()) == 0)
    }

    @Test("Buka Kira opens nothing while the store is paused")
    func pausedOpen() throws {
        let clock = TestClock()
        let (model, lock) = try unlockModel(clock: clock)
        for _ in 1...4 {
            type("000001", into: model)
            model.open()
        }
        type("00000", into: model)
        _ = lock.unlock(with: "000001")
        model.enter(1)
        model.open()
        #expect(lock.isLocked)
        #expect(model.phase == .paused(until: clock.now().addingTimeInterval(30)))
    }

    @Test("reads the clock by default")
    func defaultClock() throws {
        let vault = InMemoryVault()
        let pins = PinStore(vault: vault)
        try pins.setPin("381449")
        for _ in 1...5 { _ = pins.verify("000001") }
        let model = UnlockModel(lock: AppLockModel(pins: pins, vault: vault), email: nil)
        model.refreshPause()
        #expect(model.secondsLeft(at: .distantPast) > 0)
    }
}
