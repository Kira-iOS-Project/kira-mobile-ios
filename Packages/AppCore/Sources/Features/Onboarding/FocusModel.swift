import Domain
import Observation

/**
 Pilih Fokus (ONB-09): one choice between two cards, "Tahu Uangku Lari ke Mana" by default.
 "Belum Tahu, Lihat-Lihat Dulu" saves the default and goes on to the health check too.
 */
@MainActor @Observable
package final class FocusModel {
    /** The card chosen. */
    package var selection = Focus.trackSpending
    /** Editing, saving or failed. */
    package private(set) var phase = SubmitPhase.editing
    private let service: any OnboardingService
    private let onSaved: (Focus) -> Void

    /** A model that saves through `service` and hands the saved focus to `onSaved`. */
    package init(service: any OnboardingService, onSaved: @escaping (Focus) -> Void) {
        self.service = service
        self.onSaved = onSaved
    }

    /** "Lanjut": saves the card chosen. */
    package func submit() async {
        await save(selection)
    }

    /** "Belum Tahu": saves the default focus, whatever card is chosen. */
    package func skip() async {
        await save(.trackSpending)
    }

    private func save(_ focus: Focus) async {
        guard !phase.isSubmitting else { return }
        phase = .submitting
        do {
            try await service.saveFocus(focus)
            phase = .editing
            onSaved(focus)
        } catch {
            phase = .failure(error)
        }
    }
}
