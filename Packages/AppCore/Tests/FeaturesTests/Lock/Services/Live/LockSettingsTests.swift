import Testing

@testable import Features

@Suite("LockSettings")
struct LockSettingsTests {
    @Test("defaults: lock at once, balances shown, blurred in the app switcher")
    func defaults() {
        let settings = LockSettings()
        #expect(settings.autoLock == .immediately)
        #expect(!settings.hidesBalancesOnOpen)
        #expect(settings.obscuresInAppSwitcher)
    }

    @Test("Kunci Otomatis intervals: Segera, 1 menit, 5 menit")
    func intervals() {
        #expect(AutoLock.allCases.map(\.interval) == [0, 60, 300])
    }
}
