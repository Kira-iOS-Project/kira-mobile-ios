import APIClient
import Domain
import Observation

/**
 Isi Rencana Keselamatanku (PED-10c): the five parts to fill in, every one optional. Parts 3 and 4
 take up to three contacts, each a name and a number. Simpan Rencana saves the whole plan and shows
 "Rencana Tersimpan" (PED-10b); a failure keeps every field and offers Coba Lagi. Batal leaves
 without saving.
 */
@MainActor
@Observable
package final class SafetyPlanFormModel {
    /** A dialog over the form. */
    package enum Dialog: Hashable, Sendable {
        /** "Rencana Tersimpan". */
        case saved
        /** The save failed, with the API's problem; the fields stay. */
        case failed(AppProblem)
    }

    /** The plan being written. */
    package var plan: SafetyPlan
    /** The part whose field takes the focus when the form opens. */
    package let focus: SafetyPlanPart
    package private(set) var isSaving = false
    package private(set) var dialog: Dialog? {
        didSet { if let dialog { shownDialog = dialog } }
    }
    /** The dialog to draw, kept while a closing dialog fades out. */
    package private(set) var shownDialog = Dialog.saved
    /** True once the person leaves after saving. */
    package private(set) var isFinished = false

    private let service: any CareToolsService
    private let onSaved: @MainActor (SafetyPlan) -> Void

    /** A form on `plan`; `onSaved` receives the plan as the server stored it. */
    package init(
        plan: SafetyPlan, focus: SafetyPlanPart, service: any CareToolsService,
        onSaved: @escaping @MainActor (SafetyPlan) -> Void
    ) {
        self.plan = plan
        self.focus = focus
        self.service = service
        self.onSaved = onSaved
        if plan.people.isEmpty { self.plan.people = [SafetyContact(name: "", phone: "")] }
        if plan.professionals.isEmpty { self.plan.professionals = [SafetyContact(name: "", phone: "")] }
    }

    /** Whether part 3 or 4 can take another contact. */
    package func canAdd(to part: SafetyPlanPart) -> Bool {
        contacts(of: part).count < SafetyPlan.maximumContacts
    }

    /** Adds an empty contact to part 3 or 4. */
    package func addContact(to part: SafetyPlanPart) {
        guard canAdd(to: part) else { return }
        update(part) { $0.append(SafetyContact(name: "", phone: "")) }
    }

    /** Removes the contact at `index` of part 3 or 4. */
    package func removeContact(at index: Int, from part: SafetyPlanPart) {
        update(part) { contacts in
            if contacts.indices.contains(index) { contacts.remove(at: index) }
        }
    }

    /** Saves the plan, cleaned; the fields stay on failure. */
    package func save() async {
        dialog = nil
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            let saved = try await service.saveSafetyPlan(plan.cleaned)
            onSaved(saved)
            dialog = .saved
        } catch {
            dialog = .failed(careProblem(error))
        }
    }

    /** A dialog closed: closing "Rencana Tersimpan" leaves the form. */
    package func dialogClosed() {
        if dialog == .saved { isFinished = true }
        dialog = nil
    }

    private func contacts(of part: SafetyPlanPart) -> [SafetyContact] {
        part == .people ? plan.people : plan.professionals
    }

    private func update(_ part: SafetyPlanPart, _ change: (inout [SafetyContact]) -> Void) {
        if part == .people { change(&plan.people) } else { change(&plan.professionals) }
    }
}
