import APIClient
import Domain
import Observation

/**
 Keamanan (AKN-03): the PIN lock (turning it off asks for the PIN first), Ganti PIN, Kunci
 Otomatis, Sembunyikan Saldo (kept on the account) and the blurred app switcher (on the device).
 */
@MainActor
@Observable
package final class SecurityModel {
    /** The device's settings, once loaded. */
    package private(set) var phase: ScreenPhase<SecurityPreferences> = .loading
    /** Sembunyikan Saldo saat Membuka, from the account. */
    package private(set) var hidesBalances = false
    /** A setting the API refused to save. */
    package var problem: AppProblem?
    /** The PIN sheet, while it is up. */
    package private(set) var pinPrompt: PinPrompt?
    /** The digits typed in the PIN sheet; never stored or logged. */
    package var pin = "" {
        didSet { pinError = nil }
    }
    /** Why the last PIN step did not go on. */
    package private(set) var pinError: PinError?
    /** The Kunci Otomatis sheet is up. */
    package var isChoosingAutoLock = false
    private let service: any AccountService
    private let settings: any SecuritySettings

    /** A model over the account API and the device settings. */
    package init(service: any AccountService, settings: any SecuritySettings) {
        self.service = service
        self.settings = settings
    }

    /** The PIN sheet's button turns on once six digits are in. */
    package var canSubmitPin: Bool { pin.count == 6 }

    /** Reads the device's settings and the account's Sembunyikan Saldo. */
    package func load() async {
        let preferences = await settings.preferences()
        do {
            hidesBalances = try await service.profile().hidesBalances
            phase = .loaded(preferences)
        } catch {
            phase = .failed(accountProblem(error))
        }
    }

    /** The switch asks for a new PIN to turn the lock on, or the current one to turn it off. */
    package func setPinLock(_ isOn: Bool) {
        show(isOn ? .create : .verifyToDisable)
    }

    /** Ganti PIN: the current PIN first, then the new one. */
    package func changePin() {
        show(.verifyToChange)
    }

    /** Closes the PIN sheet without changing anything. */
    package func cancelPin() {
        pinPrompt = nil
        pin = ""
    }

    /** Runs the PIN sheet's step with the six digits typed. */
    package func submitPin() async {
        guard canSubmitPin, let pinPrompt else { return }
        switch pinPrompt {
        case .verifyToDisable:
            guard await verify() else { return }
            await settings.disablePinLock()
            await finishPin()
        case .verifyToChange:
            guard await verify() else { return }
            show(.createReplacement)
        case .create, .createReplacement:
            do {
                try await settings.setPin(pin)
                await finishPin()
            } catch {
                pinError = .notSaved
            }
        }
    }

    /** Kunci Otomatis: keeps the choice and closes the sheet. */
    package func setAutoLock(_ delay: AutoLockDelay) async {
        await settings.setAutoLock(delay)
        isChoosingAutoLock = false
        await reloadPreferences()
    }

    /** Samarkan di Pengalih Aplikasi. */
    package func setObscuresAppSwitcher(_ isOn: Bool) async {
        await settings.setObscuresAppSwitcher(isOn)
        await reloadPreferences()
    }

    /** Sembunyikan Saldo saat Membuka: shown at once, put back when the API refuses it. */
    package func setHidesBalances(_ hidden: Bool) async {
        hidesBalances = hidden
        do {
            hidesBalances = try await service.setHidesBalances(hidden).hidesBalances
        } catch {
            hidesBalances = !hidden
            problem = accountProblem(error)
        }
    }

    private func show(_ prompt: PinPrompt) {
        pin = ""
        pinPrompt = prompt
    }

    private func verify() async -> Bool {
        let isRight = await settings.verifyPin(pin)
        if !isRight { pinError = .wrong }
        return isRight
    }

    private func finishPin() async {
        cancelPin()
        await reloadPreferences()
    }

    private func reloadPreferences() async {
        phase = .loaded(await settings.preferences())
    }
}
