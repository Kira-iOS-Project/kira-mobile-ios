/**
 The "Ubah Transaksi" sheet: the draft sheet's fields (CAT-02: Nama, Jumlah with "Rp" and ",00",
 the Kategori chips, Tanggal) plus Catatan, then Batal and Simpan. Wallets do not exist yet, so the
 Dompet chips are left out. The save's result dialogs show over the sheet.
 */
import Features
import SwiftUI

struct TransactionEditForm: View {
    @Bindable var model: TransactionDetailModel
    @State private var picksDate = false

    var body: some View {
        if let editor = Binding($model.editor) {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraField("transaction.field.name", text: editor.name)
                KiraField("transaction.field.amount", text: editor.amountText)
                    .prefix("transaction.field.currency")
                    .suffix("transaction.field.cents")
                    .hint("transaction.field.amountHint")
                    .keyboardType(.numberPad)
                categories(editor)
                date(editor)
                KiraField("transaction.field.note", text: editor.note, prompt: "transaction.field.notePrompt")
                    .multiline(2)
                KiraButtonPair(
                    secondary: KiraButton("transaction.edit.cancel", variant: .secondary, size: .small) {
                        model.editor = nil
                    },
                    primary: KiraButton("transaction.edit.save", size: .small) { Task { await model.save() } }
                )
                .disabled(!editor.wrappedValue.isValid || model.isWorking)
            }
            .kiraDialog(isPresented: hasResult) { TransactionDialogs.edit(model) }
        }
    }

    private func categories(_ editor: Binding<TransactionEditor>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("transaction.field.category")
            KiraFlowRow {
                ForEach(editor.wrappedValue.categories, id: \.self) { category in
                    KiraChip(
                        category.title, isSelected: editor.wrappedValue.category == category,
                        leading: .category(category.tile)
                    ) { editor.wrappedValue.category = category }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    /** The Tanggal field: the date in full, opening a calendar with the time under it. */
    private func date(_ editor: Binding<TransactionEditor>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("transaction.field.date")
            Button {
                picksDate.toggle()
            } label: {
                HStack(spacing: KiraSpacing.space2) {
                    Text(KiraDateFormat.dateTime(editor.wrappedValue.occurredAt))
                        .font(.body).foregroundStyle(.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    KiraIcon(.calendar, size: 20).foregroundStyle(.inkMuted)
                }
                .padding(.horizontal, KiraSpacing.space4)
                .padding(.vertical, 14)
                .frame(minHeight: 52)
                .kiraCard(border: picksDate ? .pandan : .hairline, cornerRadius: KiraRadius.medium)
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text("transaction.field.dateHint"))
            if picksDate {
                DatePicker(
                    selection: editor.occurredAt, displayedComponents: [.date, .hourAndMinute]
                ) { Text("transaction.field.date") }
                .datePickerStyle(.graphical)
                .tint(.pandan)
                .environment(\.timeZone, KiraDateFormat.timeZone)
            }
        }
    }

    private func fieldLabel(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
            .foregroundStyle(.inkMuted)
            .padding(.horizontal, 4)
            .accessibilityAddTraits(.isHeader)
    }

    private var hasResult: Binding<Bool> {
        Binding(get: { model.editResult != nil }, set: { if !$0 { model.editResultClosed() } })
    }
}
