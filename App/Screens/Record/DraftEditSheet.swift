/**
 Ubah Transaksi (canvas EditDraf, CAT-02): Nama and Jumlah side by side, the category chips, the
 draft's date, then Hapus dari Draf and Simpan. Deleting asks first (EditDrafDialogHapus, CAT-02b);
 Simpan reports "Perubahan Tersimpan" (EditDrafDialogBerhasil, CAT-02c). Wallets do not exist yet,
 so the board's Dompet chips are left out.
 */
import Domain
import Features
import SwiftUI

struct DraftEditSheet: View {
    @Bindable var model: DraftEditModel
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            HStack(alignment: .top, spacing: 10) {
                KiraField("record.edit.name", text: $model.name)
                KiraField("record.edit.amount", text: $model.amountText)
                    .prefix("record.currency")
                    .suffix("record.cents")
                    .hint("record.edit.amountHint")
                    .keyboardType(.numberPad)
            }
            categories
            KiraField("record.edit.date", text: .constant(dateText))
                .icon(.calendar)
                .allowsHitTesting(false)
            Spacer(minLength: 0)
            KiraButtonPair(
                secondary: KiraButton("record.edit.delete", variant: .destructive, size: .small) {
                    model.requestDelete()
                },
                primary: KiraButton("record.edit.save", size: .small) { Task { await model.save() } }
            )
            .disabled(model.isSaving)
        }
        .onChange(of: model.isClosed) { _, closed in if closed { onClose() } }
        .kiraDialog(isPresented: $model.confirmsDelete) {
            KiraDialog(
                "record.edit.deleteTitle", message: "record.edit.deleteBody", art: .illustration(.care),
                primary: KiraButton("record.edit.deleteConfirm", variant: .destructive) {
                    Task { await model.delete() }
                },
                secondary: KiraButton("record.cancel", variant: .secondary) {})
        }
        .kiraDialog(isPresented: $model.showsSaved) {
            KiraDialog(
                "record.edit.savedTitle", message: "record.edit.savedBody", art: .illustration(.bloom),
                primary: KiraButton("record.done") { model.finish() })
        }
        .recordFailureDialog($model.failure)
    }

    private var dateText: String {
        let day = model.occurredAt.formatted(RecordFormat.weekday)
        return String(localized: "record.edit.dateValue \(day) \(model.occurredAt.formatted(RecordFormat.time))")
    }

    private var categories: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("record.edit.category")
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1)
            KiraFlowRow {
                ForEach(model.categories, id: \.self) { category in chip(category) }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func chip(_ category: TransactionCategory) -> KiraChip {
        KiraChip(category.title, isSelected: category == model.category, leading: .category(category.tile)) {
            model.select(category)
        }
    }
}
