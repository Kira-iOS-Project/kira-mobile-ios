import Domain
import Observation

/**
 Isi Rencana Keselamatanku (PED-10c): the five parts to fill in, every one optional. Parts 3 and 4
 take up to three contacts, each a name and a number. A text over 500 characters is flagged on its
 field and holds Simpan Rencana back. Simpan Rencana hands the plan to Rencana Keselamatanku, which
 saves it and closes the form; Batal leaves without saving.
 */
@MainActor
@Observable
package final class SafetyPlanFormModel {
    /** The plan being written. */
    package var plan: SafetyPlan
    /** The part whose field takes the focus when the form opens. */
    package let focus: SafetyPlanPart
    /** Whether Simpan Rencana is on its way. */
    package private(set) var isSaving = false

    private let onSave: @MainActor (SafetyPlan, SafetyPlanPart) async -> Void

    /** A form on `plan`; `onSave` saves what was written, with the part the form opened on. */
    package init(
        plan: SafetyPlan, focus: SafetyPlanPart,
        onSave: @escaping @MainActor (SafetyPlan, SafetyPlanPart) async -> Void
    ) {
        self.plan = plan
        self.focus = focus
        self.onSave = onSave
        if plan.people.isEmpty { self.plan.people = [SafetyContact(name: "", phone: "")] }
        if plan.professionals.isEmpty { self.plan.professionals = [SafetyContact(name: "", phone: "")] }
    }

    /** Whether Simpan Rencana can go: no text is over the limit and no save is running. */
    package var canSave: Bool { !plan.isTooLong && !isSaving }

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

    /** Simpan Rencana: hands the plan over to be saved, once at a time. */
    package func save() async {
        guard canSave else { return }
        isSaving = true
        defer { isSaving = false }
        await onSave(plan, focus)
    }

    private func contacts(of part: SafetyPlanPart) -> [SafetyContact] {
        part == .people ? plan.people : plan.professionals
    }

    private func update(_ part: SafetyPlanPart, _ change: (inout [SafetyContact]) -> Void) {
        if part == .people { change(&plan.people) } else { change(&plan.professionals) }
    }
}
