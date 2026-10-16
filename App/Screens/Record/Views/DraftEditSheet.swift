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
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            /** The fields scroll at large text sizes, so none is cut off; the two buttons stay at the bottom. */
            ScrollView {
                fields
            }
            .scrollBounceBehavior(.basedOnSize)
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
    }

    /** Nama and Jumlah side by side, the category chips and the draft's date. */
    private var fields: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            /** Side by side as on the board; stacked at the accessibility sizes, where half a row cuts the values. */
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: KiraSpacing.space3) { nameAndAmount }
            } else {
                HStack(alignment: .top, spacing: 10) { nameAndAmount }
            }
            categories
            dateRow
        }
    }

    @ViewBuilder private var nameAndAmount: some View {
        KiraField("record.edit.name", text: $model.name)
        KiraField("record.edit.amount", text: $model.amountText)
            .amount()
            .prefix("record.currency")
            .suffix("record.cents")
            .hint("record.edit.amountHint")
            .keyboardType(.numberPad)
    }

    /**
     The draft's date, read only: drawn like a field (its label above a hairline box with the
     calendar icon) but as text, which wraps at large sizes where a field's single line is cut off.
     */
    private var dateRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("record.edit.date")
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted)
                .padding(.horizontal, 4)
                .accessibilityHidden(true)
            HStack(spacing: KiraSpacing.space2) {
                Text(dateText).font(.body).foregroundStyle(.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                KiraIcon(.calendar, size: 20).foregroundStyle(.inkMuted)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, KiraSpacing.space4)
            .frame(minHeight: 52)
            .kiraCard(cornerRadius: KiraRadius.medium)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("record.edit.date"))
            .accessibilityValue(Text(dateText))
        }
    }

    private var dateText: String {
        let day = model.occurredAt.formatted(.kiraWeekdayDate)
        return String(localized: "record.edit.dateValue \(day) \(model.occurredAt.formatted(.kiraTime))")
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
