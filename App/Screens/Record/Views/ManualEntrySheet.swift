/**
 Catat Manual (canvas CatatManual, CatatManualPemasukan; CAT-04, CAT-04d): Pengeluaran or
 Pemasukan, the big amount with its caret and ",00" added, the category tiles, then Nama, Tanggal and
 Catatan in one card, and Simpan. Saving reports "Transaksi Tersimpan" (CAT-04b); a failed save
 closes the sheet for "Belum Berhasil Menyimpan" with Coba Lagi, every field kept (CAT-04c). No AI
 quota is used.
 */
import Domain
import Features
import SwiftUI

struct ManualEntrySheet: View {
    @Bindable var model: ManualEntryModel
    let onClose: () -> Void
    @FocusState private var isAmountFocused: Bool

    var body: some View {
        VStack(spacing: 18) {
            /** All but Simpan scrolls, so nothing is squeezed out of the sheet at the larger text sizes. */
            ScrollView {
                VStack(spacing: 18) {
                    KiraSegmented(
                        "record.manual.type",
                        options: [
                            .init(id: TransactionType.expense, title: "record.manual.expense"),
                            .init(id: TransactionType.income, title: "record.manual.income"),
                        ],
                        selection: Binding(get: { model.type }, set: { model.select($0) }))
                    ManualAmountInput(model: model, isFocused: $isAmountFocused)
                    ManualCategoryGrid(model: model)
                    ManualDetails(model: model)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            /**
             Simpan stays as the board draws it, never dimmed: without an amount it opens the number pad
             on Jumlah instead of saving.
             */
            KiraButton(model.type == .income ? "record.manual.saveIncome" : "record.manual.save") {
                if model.canSave {
                    Task { await model.save() }
                } else {
                    isAmountFocused = true
                }
            }
            .block()
            .disabled(model.isSaving)
        }
        .onChange(of: model.isClosed) { _, closed in if closed { onClose() } }
        .kiraDialog(isPresented: $model.showsSaved) {
            KiraDialog(
                "record.manual.savedTitle", message: "record.manual.savedBody", art: .illustration(.bloom),
                primary: KiraButton("record.done") { model.finish() })
        }
    }
}

/** "Jumlah": the amount in the extra-large style with a pandan caret, typed on the number pad. */
private struct ManualAmountInput: View {
    @Bindable var model: ManualEntryModel
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: KiraSpacing.space1) {
            Text("record.manual.amount").kiraFont(.overline).foregroundStyle(.inkMuted)
            HStack(spacing: KiraSpacing.space1) {
                KiraAmount(Decimal(model.amount), size: .extraLarge)
                RoundedRectangle(cornerRadius: 1).fill(.pandan).frame(width: 2, height: 36)
                    .opacity(isFocused.wrappedValue ? 1 : 0.4)
                    .accessibilityHidden(true)
            }
            .overlay {
                /** A clear prompt: the label stays for VoiceOver, never drawn over the amount. */
                TextField(text: $model.amountText, prompt: Text("record.manual.amount").foregroundStyle(.clear)) {
                    Text("record.manual.amount")
                }
                .keyboardType(.numberPad)
                .focused(isFocused)
                .foregroundStyle(.clear)
                .tint(.clear)
            }
            Text("record.manual.amountHint")
                .font(.footnote).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
