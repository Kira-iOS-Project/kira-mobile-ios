/**
 PED-10c, Isi Rencana Keselamatanku (board RencanaKeselamatanIsi): a field per part with the
 board's hints, every one optional; parts 3 and 4 hold up to three contacts, a name and a number
 each, because a number is what the plan's link calls. A text over 500 characters is flagged on its
 field. Batal and Simpan Rencana sit at the board's 1 : 1.3; Simpan Rencana hands the plan to
 Rencana Keselamatanku, which saves it and closes this screen.
 */
import Domain
import Features
import SwiftUI

struct SafetyPlanFormScreen: View {
    @Bindable var form: SafetyPlanFormModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        CareScreenFrame(twigSize: 150) {
            SafetyPlanHeader(
                title: "care.plan.form.title", lead: "care.plan.form.lead", back: "care.plan.form.back"
            ) { dismiss() }
            VStack(alignment: .leading, spacing: 14) {
                text(.warningSigns, $form.plan.warningSigns)
                text(.calmingThings, $form.plan.calmingThings)
                SafetyContactFields(form: form, part: .people)
                SafetyContactFields(form: form, part: .professionals)
                text(.safePlace, $form.plan.safePlace)
            }
            KiraNotice(.privacy, message: "care.plan.notice")
            Spacer(minLength: 0)
            actions
        }
    }

    private func text(_ part: SafetyPlanPart, _ value: Binding<String>) -> some View {
        KiraField(part.title, text: value)
            .multiline(2)
            .hint(part.hint)
            .error(SafetyPlan.isTooLong(value.wrappedValue) ? "care.plan.tooLong" : nil)
    }

    /** "Batal" and "Simpan Rencana" in the board's 1 : 1.3 columns, stacked at accessibility sizes. */
    @ViewBuilder private var actions: some View {
        let cancel = KiraButton("care.plan.form.cancel", variant: .secondary, size: .small) { dismiss() }
        let save = KiraButton("care.plan.save", size: .small) { Task { await form.save() } }
        Group {
            if typeSize.isAccessibilitySize {
                KiraButtonPair(secondary: cancel, primary: save)
            } else {
                WeightedRow(weights: [1, 1.3], spacing: 10) {
                    cancel.block()
                    save.block().disabled(!form.canSave)
                }
            }
        }
        .disabled(form.isSaving)
    }
}

/**
 Part 3 or 4 of the form: its label and hint over one "Nama" and "Nomor Telepon" pair per contact
 (each removable once there is more than one), and Tambah Kontak while there are fewer than three.
 */
private struct SafetyContactFields: View {
    @Bindable var form: SafetyPlanFormModel
    let part: SafetyPlanPart

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            Text(part.title)
                .font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15).foregroundStyle(.ink)
                .accessibilityAddTraits(.isHeader)
            ForEach(contacts.wrappedValue.indices, id: \.self) { index in
                contact(at: index)
            }
            Text(part.hint).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            if form.canAdd(to: part) {
                KiraButton("care.plan.contact.add", variant: .secondary, size: .small) {
                    form.addContact(to: part)
                }
                .icon(.plus).block()
            }
        }
    }

    private func contact(at index: Int) -> some View {
        let contact = contacts[index]
        return HStack(alignment: .top, spacing: KiraSpacing.space2) {
            VStack(spacing: KiraSpacing.space2) {
                KiraField("care.plan.contact.name", text: contact.name)
                    .error(SafetyPlan.isTooLong(contact.name.wrappedValue) ? "care.plan.tooLong" : nil)
                KiraField("care.plan.contact.phone", text: contact.phone)
                    .keyboardType(.phonePad)
                    .error(SafetyPlan.isTooLong(contact.phone.wrappedValue) ? "care.plan.tooLong" : nil)
            }
            if contacts.wrappedValue.count > 1 {
                KiraIconButton(.trash, label: "care.plan.contact.remove") {
                    form.removeContact(at: index, from: part)
                }
            }
        }
    }

    private var contacts: Binding<[SafetyContact]> {
        part == .people ? $form.plan.people : $form.plan.professionals
    }
}
