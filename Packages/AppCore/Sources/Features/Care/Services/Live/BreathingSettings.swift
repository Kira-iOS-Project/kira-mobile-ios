import Foundation

/**
 Whether Latihan Menenangkan Diri taps the phone at each step ("Getaran Halus"), kept on this phone
 only and never sent. On until the person turns it off.
 */
package struct BreathingSettings: @unchecked Sendable {
    private static let hapticsKey = "care.breathing.haptics"
    private let defaults: UserDefaults

    /** The setting kept in `defaults`. */
    package init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /** Whether the taps are on. */
    package var hapticsOn: Bool {
        defaults.object(forKey: Self.hapticsKey) as? Bool ?? true
    }

    /** Keeps the person's choice. */
    package func setHapticsOn(_ isOn: Bool) {
        defaults.set(isOn, forKey: Self.hapticsKey)
    }
}
