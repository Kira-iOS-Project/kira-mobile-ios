/**
 Catat Manual (canvas CatatManual, CatatManualPemasukan; CAT-04, CAT-04d): Pengeluaran or
 Pemasukan, the big amount with its caret and ",00" added, the category tiles, then Nama, Tanggal and
 Catatan in one card, and Simpan. Saving reports "Transaksi Tersimpan" (CAT-04b); a lost connection
 reports "Belum Berhasil Menyimpan" with Coba Lagi, every field kept (CAT-04c). No AI quota is used.
 */
import Domain
import Features
import SwiftUI

struct ManualEntrySheet: View {
    @Bindable var model: ManualEntryModel
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            KiraSegmented(
                "record.manual.type",
                options: [
                    .init(id: TransactionType.expense, title: "record.manual.expense"),
                    .init(id: TransactionType.income, title: "record.manual.income"),
                ],
                selection: Binding(get: { model.type }, set: { model.select($0) }))
            ScrollView {
                VStack(spacing: 18) {
                    ManualAmountInput(model: model)
                    ManualCategoryGrid(model: model)
                    ManualDetails(model: model)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            KiraButton(model.type == .income ? "record.manual.saveIncome" : "record.manual.save") {
                Task { await model.save() }
            }
            .block()
            .disabled(!model.canSave)
        }
        .onChange(of: model.isClosed) { _, closed in if closed { onClose() } }
        .kiraDialog(isPresented: $model.showsSaved) {
            KiraDialog(
                "record.manual.savedTitle", message: "record.manual.savedBody", art: .illustration(.bloom),
                primary: KiraButton("record.done") { model.finish() })
        }
        .kiraDialog(
            isPresented: Binding(get: { model.failure == .connection }, set: { if !$0 { model.failure = nil } })
        ) {
            KiraDialog(
                "record.manual.failedTitle", message: "record.manual.failedBody", art: .illustration(.umbrella),
                primary: KiraButton("record.retry") { Task { await model.save() } },
                secondary: KiraButton("ds.close", variant: .secondary) {})
        }
        .recordFailureDialog(
            Binding(get: { model.failure == .connection ? nil : model.failure }, set: { model.failure = $0 }))
    }
}

/** "Jumlah": the amount in the extra-large style with a pandan caret, typed on the number pad. */
private struct ManualAmountInput: View {
    @Bindable var model: ManualEntryModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: KiraSpacing.space1) {
            Text("record.manual.amount").kiraFont(.overline).foregroundStyle(.inkMuted)
            HStack(spacing: KiraSpacing.space1) {
                KiraAmount(Decimal(model.amount), size: .extraLarge)
                RoundedRectangle(cornerRadius: 1).fill(.pandan).frame(width: 2, height: 36)
                    .opacity(isFocused ? 1 : 0.4)
                    .accessibilityHidden(true)
            }
            .overlay {
                /** A clear prompt: the label stays for VoiceOver, never drawn over the amount. */
                TextField(text: $model.amountText, prompt: Text("record.manual.amount").foregroundStyle(.clear)) {
                    Text("record.manual.amount")
                }
                .keyboardType(.numberPad)
                .focused($isFocused)
                .foregroundStyle(.clear)
                .tint(.clear)
            }
            Text("record.manual.amountHint")
                .font(.footnote).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .onAppear { isFocused = true }
    }
}
