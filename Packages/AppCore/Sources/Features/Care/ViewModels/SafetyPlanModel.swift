import APIClient
import Domain
import Observation

/**
 Rencana Keselamatanku (PED-10): the five parts as saved, each with a pencil that opens the form
 (PED-10c). A plan never saved is an empty plan, not a failure (`GET` answers 404). Parts 3 and 4
 list their contacts, each a number the person can tap to call. Simpan Rencana, here or on the
 form, saves the whole plan and shows "Rencana Tersimpan" (PED-10b), whose Selesai goes back to
 Kira Peduli. A failed save closes the form and shows the failure dialog; Coba Lagi opens the form
 again with everything the person wrote, and Tutup keeps it for the next pencil.
 */
@MainActor
@Observable
package final class SafetyPlanModel {
    /** A dialog over the plan. */
    package enum Dialog: Hashable, Sendable {
        /** "Rencana Tersimpan". */
        case saved
        /** The save failed, with the API's problem; what was written is kept. */
        case failed(AppProblem)
    }

    /** The plan once loaded, empty when none was saved. */
    package private(set) var phase: ScreenPhase<SafetyPlan> = .loading
    /** The open form; nil while the plan shows. */
    package var form: SafetyPlanFormModel?
    /** Whether a save is on its way. */
    package private(set) var isSaving = false
    /** The dialog over the plan, nil when none shows. */
    package private(set) var dialog: Dialog? {
        didSet { if let dialog { shownDialog = dialog } }
    }
    /** The dialog to draw, kept while a closing dialog fades out. */
    package private(set) var shownDialog = Dialog.saved
    /** True once "Rencana Tersimpan" closes: the screen goes back to Kira Peduli. */
    package private(set) var isFinished = false

    /** What the person wrote in a save that failed, with the part they were on. */
    private var unsaved: (plan: SafetyPlan, focus: SafetyPlanPart)?
    private let service: any CareToolsService

    /** A plan read and saved through `service`. */
    package init(service: any CareToolsService) {
        self.service = service
    }

    /** Loads the saved plan, or the empty one. */
    package func load() async {
        do {
            phase = .loaded(try await service.safetyPlan() ?? .empty)
        } catch {
            phase = .failed(careProblem(error))
        }
    }

    /** Opens the form focused on `part`, on what a failed save kept or else on the plan as it shows. */
    package func edit(_ part: SafetyPlanPart) {
        open(unsaved?.plan ?? phase.value ?? .empty, focus: part)
    }

    /** Simpan Rencana under the plan: saves it as it shows. */
    package func saveShown() async {
        guard let plan = phase.value else { return }
        await save(plan, focus: .warningSigns)
    }

    /** Saves `plan`, cleaned; the form closes either way, and a failure keeps `plan` for Coba Lagi. */
    package func save(_ plan: SafetyPlan, focus: SafetyPlanPart) async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            phase = .loaded(try await service.saveSafetyPlan(plan.cleaned))
            unsaved = nil
            form = nil
            dialog = .saved
        } catch {
            unsaved = (plan, focus)
            form = nil
            dialog = .failed(careProblem(error))
        }
    }

    /** Coba Lagi: the form again, with what the person wrote. */
    package func retry() {
        dialog = nil
        guard let unsaved else { return }
        open(unsaved.plan, focus: unsaved.focus)
    }

    /** A dialog closed: closing "Rencana Tersimpan" leaves the screen; Tutup keeps the unsaved plan. */
    package func dialogClosed() {
        if dialog == .saved { isFinished = true }
        dialog = nil
    }

    private func open(_ plan: SafetyPlan, focus: SafetyPlanPart) {
        form = SafetyPlanFormModel(plan: plan, focus: focus) { [weak self] written, part in
            await self?.save(written, focus: part)
        }
    }
}

/** A part of the plan, in the board's order. */
package enum SafetyPlanPart: Int, CaseIterable, Hashable, Sendable {
    /** 1. Tanda Aku Mulai Berat. */
    case warningSigns = 1
    /** 2. Hal yang Menenangkanku. */
    case calmingThings
    /** 3. Orang yang Bisa Kuhubungi. */
    case people
    /** 4. Layanan Profesional. */
    case professionals
    /** 5. Tempat Aku Merasa Aman. */
    case safePlace
}
