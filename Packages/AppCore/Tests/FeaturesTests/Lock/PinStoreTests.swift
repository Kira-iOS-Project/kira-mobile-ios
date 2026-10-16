import Domain
import Foundation
import Testing

@testable import Features

private func pins(_ vault: InMemoryVault = InMemoryVault(), clock: TestClock = TestClock()) -> PinStore {
    PinStore(vault: vault, now: clock.now) { Data([1, 2, 3, 4]) }
}

@Suite("PinStore")
struct PinStoreTests {
    @Test("keeps a salted hash, never the PIN")
    func storesHash() throws {
        let vault = InMemoryVault()
        let store = pins(vault)
        #expect(!store.hasPin)
        try store.setPin("381449")
        #expect(store.hasPin)
        let stored = try #require(vault.data(for: .pin))
        #expect(stored.range(of: Data("381449".utf8)) == nil)
        #expect(store.verify("381449") == .correct)
    }

    @Test("salts each PIN with fresh random bytes and reads the clock by default")
    func randomSalt() throws {
        let one = InMemoryVault()
        let two = InMemoryVault()
        try PinStore(vault: one).setPin("381449")
        try PinStore(vault: two).setPin("381449")
        #expect(one.data(for: .pin) != two.data(for: .pin))
        let store = PinStore(vault: one)
        for _ in 1...5 { _ = store.verify("000001") }
        #expect(store.pausedUntil() != nil)
    }

    @Test("refuses a PIN the policy refuses")
    func refusesWeak() {
        let store = pins()
        #expect(throws: PinProblem.tooSimple) { try store.setPin("111111") }
        #expect(throws: PinProblem.notSixDigits) { try store.setPin("1234") }
        #expect(!store.hasPin)
    }

    @Test("counts wrong tries, then pauses 30 seconds, remembered by a new store")
    func pauses() throws {
        let vault = InMemoryVault()
        let clock = TestClock()
        let store = pins(vault, clock: clock)
        try store.setPin("381449")
        let checks = (1...4).map { _ in store.verify("000001") }
        #expect(checks == [4, 3, 2, 1].map { .wrong(remainingAttempts: $0) })
        let until = clock.now().addingTimeInterval(30)
        #expect(store.verify("000001") == .paused(until: until))
        let reopened = pins(vault, clock: clock)
        #expect(reopened.pausedUntil() == until)
        #expect(reopened.verify("381449") == .paused(until: until))
        clock.advance(30)
        #expect(reopened.pausedUntil() == nil)
        #expect(reopened.verify("000001") == .wrong(remainingAttempts: 4))
    }

    @Test("a right PIN starts the count again")
    func resetsCount() throws {
        let store = pins()
        try store.setPin("381449")
        _ = store.verify("000001")
        #expect(store.verify("381449") == .correct)
        #expect(store.verify("000001") == .wrong(remainingAttempts: 4))
    }

    @Test("without a PIN, or with an unreadable one, nothing is right")
    func noPin() {
        #expect(pins().verify("381449") == .wrong(remainingAttempts: 0))
        let broken = pins(InMemoryVault([.pin: Data("x".utf8)]))
        #expect(!broken.hasPin)
        #expect(broken.pausedUntil() == nil)
    }

    @Test("removing the PIN opens Kira without one")
    func removes() throws {
        let store = pins()
        try store.setPin("381449")
        store.removePin()
        #expect(!store.hasPin)
    }
}
