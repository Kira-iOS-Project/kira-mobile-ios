/**
 The two groups of Tinjau Hasil Impor: "Mungkin Dobel · N", whose rows a tap checks, and "Siap
 Disimpan · N", whose rows a tap opens; the ready rows past the first five fold into one
 "N Transaksi Lainnya" row until it is tapped.
 */
import Domain
import Features
import SwiftUI

struct ImportReviewGroups: View {
    let model: ImportReviewModel

    var body: some View {
        if !model.duplicates.isEmpty {
            KiraListGroup(
                "review.duplicates.title \(model.duplicates.count)", footer: "review.duplicates.footer"
            ) {
                ForEach(model.duplicates) { row in
                    rowView(row) { model.toggle(row) }
                }
            }
        }
        if !model.ready.isEmpty {
            KiraListGroup("review.ready.title \(model.ready.count)", footer: "review.ready.footer") {
                ForEach(model.visibleReady) { row in
                    rowView(row) { model.editingRowId = row.id }
                }
                if !model.hiddenReady.isEmpty { foldedRow }
            }
        }
    }

    private func rowView(_ row: ImportPreviewRow, action: @escaping () -> Void) -> some View {
        let category = model.category(of: row)
        let amount = KiraAmount(Decimal(row.amount), size: .small)
        return KiraListRow(
            Text(row.description), leading: .category(category.artwork), trailing: .check(model.isChecked(row)),
            action: action
        )
        .subtitle(Text("review.row.details \(Text(category.title)) \(KiraDateFormat.day.format(row.day.start))"))
        .amount(row.type == .income ? amount.signed() : amount)
    }

    private var foldedRow: some View {
        let hidden = model.hiddenReady
        let checked = hidden.count(where: model.isChecked)
        let subtitle: LocalizedStringResource =
            checked == hidden.count ? "review.more.allChecked" : "review.more.someChecked \(checked)"
        return KiraListRow(Text("review.more.title \(hidden.count)"), leading: .icon(.list), trailing: .chevron) {
            model.showAllReady()
        }
        .subtitle(Text(subtitle))
    }
}

/** The sheet of one imported row: leave it in or out, and the category it is saved under. */
struct ImportRowSheet: View {
    let model: ImportReviewModel

    var body: some View {
        if let row = model.editingRow {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                Text(row.description).kiraFont(.title).foregroundStyle(.ink)
                KiraAmount(Decimal(row.amount), size: .medium)
                KiraCheckbox(
                    "review.row.include",
                    isOn: Binding(get: { model.isChecked(row) }, set: { _ in model.toggle(row) }))
                Text("review.row.category")
                    .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                    .foregroundStyle(.inkMuted)
                    .accessibilityAddTraits(.isHeader)
                KiraFlowRow {
                    ForEach(model.categories(for: row), id: \.self) { category in
                        KiraChip(
                            category.title, isSelected: model.category(of: row) == category,
                            leading: .category(category.artwork)
                        ) { model.setCategory(category, for: row) }
                    }
                }
                KiraButton("review.row.done") { model.editingRowId = nil }.block()
            }
        }
    }
}
