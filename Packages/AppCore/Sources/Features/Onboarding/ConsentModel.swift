import Domain
import Observation

/**
 Persetujuan Data (ONB-08): the core purpose is locked on; Kira AI and the weekly summary start on
 and can be turned off. "Setuju dan Lanjut" saves the choices with the policy version (server).
 */
@MainActor @Observable
package final class ConsentModel {
    /** "Kira AI Membaca Chat dan Struk". */
    package var aiProcessing = true
    /** "Ringkasan Mingguan". */
    package var weeklySummary = true
    /** Editing, saving or failed. */
    package private(set) var phase = SubmitPhase.editing
    private let service: any OnboardingService
    private let onSaved: () -> Void

    /** A model that saves through `service` and then runs `onSaved`. */
    package init(service: any OnboardingService, onSaved: @escaping () -> Void) {
        self.service = service
        self.onSaved = onSaved
    }

    /** Saves the choices and moves on. */
    package func submit() async {
        guard !phase.isSubmitting else { return }
        phase = .submitting
        do {
            try await service.saveConsents(ConsentChoices(aiProcessing: aiProcessing, weeklySummary: weeklySummary))
            phase = .editing
            onSaved()
        } catch {
            phase = .failure(error)
        }
    }
}
