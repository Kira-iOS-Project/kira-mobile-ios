import Domain
import Observation

/**
 Kunci Kira (ONB-14, ONB-14b): six digits on the number pad, hidden as dots unless held; a PIN of
 one digit repeated is refused. "Buat PIN" keeps it on the device and shows "PIN Berhasil Dibuat";
 "Nanti Saja" goes on without a lock. "Sembunyikan Saldo" is saved to the account either way.
 */
@MainActor @Observable
package final class PinSetupModel {
    /** The digits typed so far; never logged, never sent. */
    package var pin = "" {
        didSet { if showsWeakPin, pin != oldValue { showsWeakPin = false } }
    }
    /** "Sembunyikan Saldo saat Membuka Kira". */
    package var hidesBalances = false
    /** Whether the last try was one digit repeated. */
    package private(set) var showsWeakPin = false
    /** Whether "PIN Berhasil Dibuat" is showing. */
    package var showsSuccess = false
    /** Editing, saving or failed. */
    package private(set) var phase = SubmitPhase.editing
    private let service: any OnboardingService
    private let pinSetup: any PinSetup
    private let onFinished: () -> Void

    /** A model saving through `service` and `pinSetup`; `onFinished` opens Beranda. */
    package init(service: any OnboardingService, pinSetup: any PinSetup, onFinished: @escaping () -> Void) {
        self.service = service
        self.pinSetup = pinSetup
        self.onFinished = onFinished
    }

    /** Whether all six digits are in, so "Buat PIN" can be tapped. */
    package var isComplete: Bool { pin.count == PinRule.length }

    /** "Buat PIN": refuses a repeated digit, else saves the choice and the PIN, then shows the dialog. */
    package func createPin() async {
        guard isComplete, !phase.isSubmitting else { return }
        guard PinRule.isAcceptable(pin) else {
            showsWeakPin = true
            return
        }
        guard await save({ [pin, pinSetup] in try await pinSetup.save(pin: pin) }) else { return }
        showsSuccess = true
    }

    /** "Nanti Saja": saves the balance choice and goes on without a lock. */
    package func skip() async {
        guard await save(nil) else { return }
        onFinished()
    }

    /** "Mulai" on the dialog. */
    package func start() {
        onFinished()
    }

    /** Saves "Sembunyikan Saldo" when on, then runs `then`; false when either failed. */
    private func save(_ then: (@Sendable () async throws -> Void)?) async -> Bool {
        guard !phase.isSubmitting else { return false }
        phase = .submitting
        do {
            if hidesBalances { try await service.saveHideBalances(true) }
            try await then?()
            phase = .editing
            return true
        } catch {
            phase = .failure(error)
            return false
        }
    }
}
