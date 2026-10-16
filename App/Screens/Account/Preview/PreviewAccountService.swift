/**
 The account API before integration: answers with the boards' sample data after a short pause,
 keeps the switches it is given, and succeeds at everything. The integrator replaces it with the
 generated client's implementation of AccountService.
 */
import Domain
import Features

/** An AccountService that answers from AccountSamples. */
actor PreviewAccountService: AccountService {
    private var profileValue = AccountSamples.profile
    private var consentsValue = AccountSamples.consents()

    func profile() async throws -> AccountProfile {
        await pause()
        return profileValue
    }

    func setHidesBalances(_ hidden: Bool) throws -> AccountProfile {
        let old = profileValue
        profileValue = AccountProfile(
            id: old.id, email: old.email, displayName: old.displayName, plan: old.plan, usage: old.usage,
            period: old.period, debtAccountCount: old.debtAccountCount, hidesBalances: hidden, aiEnabled: old.aiEnabled,
            weeklySummaryEnabled: old.weeklySummaryEnabled)
        return profileValue
    }

    func consents() throws -> ConsentSettings { consentsValue }

    func updateConsents(aiProcessing: Bool, weeklySummary: Bool) throws -> ConsentSettings {
        consentsValue = AccountSamples.consents(aiProcessing: aiProcessing, weekly: weeklySummary)
        return consentsValue
    }

    func exportData() throws -> DataExport { AccountSamples.export }

    func emailExport() async throws { await pause() }

    func deleteAccount(confirmation _: String) async throws { await pause() }

    func signOut() throws {}

    private func pause() async {
        try? await Task.sleep(for: .milliseconds(300))
    }
}

/** The device's PIN store and lock settings before integration, in memory: the PIN is 123456. */
actor PreviewSecuritySettings: SecuritySettings {
    private var pin: String? = "123456"
    private var autoLock = AutoLockDelay.immediately
    private var obscures = true

    func preferences() -> SecurityPreferences {
        SecurityPreferences(isPinLockEnabled: pin != nil, autoLock: autoLock, obscuresAppSwitcher: obscures)
    }

    func verifyPin(_ candidate: String) -> Bool { candidate == pin }
    func setPin(_ newPin: String) throws { pin = newPin }
    func disablePinLock() { pin = nil }
    func setAutoLock(_ delay: AutoLockDelay) { autoLock = delay }
    func setObscuresAppSwitcher(_ isOn: Bool) { obscures = isOn }
    func clearLocalData() { pin = nil }
}
