/**
 Tambah Rincian Utang (ONB-11b): the kind as chips, the name, what is left, the instalment and the
 optional tenor. Amounts are digits only with ",00" beside the box. "Simpan Utang" adds the row,
 or changes the debt the sheet was opened from.
 */
import Domain
import Features
import SwiftUI

struct DebtFormSheet: View {
    let debts: DebtAnswersModel
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            DebtFormFields(form: debts.form)
        }
        .scrollBounceBehavior(.basedOnSize)
        actions.padding(.bottom, KiraSpacing.space2)
    }

    /** "Batal" and "Simpan Utang" in the board's 1 : 1.3 columns, stacked at accessibility sizes. */
    @ViewBuilder private var actions: some View {
        let cancel = KiraButton("onboarding.cancel", variant: .secondary) { debts.isFormPresented = false }
        let save = KiraButton("onboarding.debt.save") { debts.saveForm() }
        if typeSize.isAccessibilitySize {
            KiraButtonPair(secondary: cancel, primary: save)
        } else {
            WeightedRow(weights: [1, 1.3], spacing: KiraSpacing.space2) {
                cancel.block()
                save.block()
            }
        }
    }
}

private struct DebtFormFields: View {
    @Bindable var form: DebtFormModel

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                Text("onboarding.debt.sheet.kind").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                    .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1)
                KiraFlowRow {
                    ForEach(DebtKind.allCases, id: \.self) { kind in
                        KiraChip(kind.title, isSelected: form.kind == kind, leading: .category(kind.category)) {
                            form.kind = kind
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            KiraField("onboarding.debt.sheet.name", text: $form.name, prompt: "onboarding.debt.sheet.name.prompt")
                .error(missing(form.name, "onboarding.debt.sheet.name.missing"))
            amountField("onboarding.debt.sheet.remaining", text: $form.remaining)
                .error(missing(form.remaining, "onboarding.debt.sheet.remaining.missing"))
            amountField("onboarding.debt.sheet.instalment", text: $form.instalment)
                .error(missing(form.instalment, "onboarding.debt.sheet.instalment.missing"))
            KiraField("onboarding.debt.sheet.tenor", text: $form.tenor, prompt: "onboarding.debt.sheet.zero")
                .suffix("onboarding.debt.sheet.months")
                .hint("onboarding.debt.sheet.tenor.hint")
                .keyboardType(.numberPad)
            KiraField("onboarding.debt.sheet.interest", text: $form.interest, prompt: "onboarding.debt.sheet.zero")
                .suffix("onboarding.debt.sheet.percent")
                .hint("onboarding.debt.sheet.interest.hint")
                .error(form.isInterestInvalid ? "onboarding.debt.sheet.interest.invalid" : nil)
                .keyboardType(.decimalPad)
            KiraField("onboarding.debt.sheet.dueDay", text: $form.dueDay, prompt: "onboarding.debt.sheet.dueDay.prompt")
                .hint("onboarding.debt.sheet.dueDay.hint")
                .error(form.isDueDayInvalid ? "onboarding.debt.sheet.dueDay.invalid" : nil)
                .keyboardType(.numberPad)
        }
        .padding(.bottom, KiraSpacing.space2)
    }

    private func amountField(_ label: LocalizedStringResource, text: Binding<String>) -> KiraField {
        KiraField(label, text: text, prompt: "onboarding.debt.sheet.zero")
            .amount()
            .prefix("onboarding.quiz.currency")
            .suffix("onboarding.quiz.cents")
    }

    /** The calm sentence under a field left empty, once a save was refused. */
    private func missing(_ text: String, _ message: LocalizedStringResource) -> LocalizedStringResource? {
        form.showsMissing && text.trimmingCharacters(in: .whitespaces).isEmpty ? message : nil
    }
}
