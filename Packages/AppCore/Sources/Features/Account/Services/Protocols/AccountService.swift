import APIClient
import Domain

/**
 The account's calls to the API (CONTRACT "Account"): the profile, its settings, the consents, the
 data export, the deletion and signing out. Each failure is thrown as an `AppProblem`. The
 integrator implements it with the generated client; previews use `PreviewAccountService`.
 */
package protocol AccountService: Sendable {
    /** `GET /me`. */
    func profile() async throws -> AccountProfile
    /** `PATCH /me {hideBalances}`: Sembunyikan Saldo saat Membuka. */
    func setHidesBalances(_ hidden: Bool) async throws -> AccountProfile
    /** `GET /me/consents`. */
    func consents() async throws -> ConsentSettings
    /** `PUT /me/consents {aiProcessing, weeklySummary}`; takes effect at once. */
    func updateConsents(aiProcessing: Bool, weeklySummary: Bool) async throws -> ConsentSettings
    /** `GET /me/export`: the CSV to save on the device. */
    func exportData() async throws -> DataExport
    /** `POST /me/export/email`: the same CSV, emailed to the account's address. */
    func emailExport() async throws
    /** `POST /me/deletion {confirmation}`: deletes the account and its data, and ends the session. */
    func deleteAccount(confirmation: String) async throws
    /** `POST /auth/sign-out`, then forgets the tokens on this device. */
    func signOut() async throws
}

/**
 The app lock's settings on this device (AKN-03), implemented with the PIN store and the app lock
 (agent I0). The PIN is checked and kept on the device only, hashed, and never logged.
 */
package protocol SecuritySettings: Sendable {
    /** The current settings. */
    func preferences() async -> SecurityPreferences
    /** Whether `pin` is the PIN that locks Kira. */
    func verifyPin(_ pin: String) async -> Bool
    /** Keeps `pin` as the PIN and turns the lock on (Kunci dengan PIN, Ganti PIN). */
    func setPin(_ pin: String) async throws
    /** Forgets the PIN and turns the lock off. */
    func disablePinLock() async
    /** Kunci Otomatis: Segera, 1 menit or 5 menit. */
    func setAutoLock(_ delay: AutoLockDelay) async
    /** Samarkan di Pengalih Aplikasi. */
    func setObscuresAppSwitcher(_ isOn: Bool) async
    /** Forgets everything this device keeps for the account (PIN, settings, caches) on sign-out. */
    func clearLocalData() async
}

/** The thrown error as the API's problem, or the generic one when it is anything else. */
func accountProblem(_ error: any Error) -> AppProblem {
    (error as? AppProblem) ?? AppProblem()
}
