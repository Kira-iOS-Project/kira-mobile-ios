/**
 The parts of Catat Manual below the amount: the "Kategori" tiles, four to a row, the chosen one
 pandan on pandan-soft; and the card with Nama, Tanggal (a calendar opens under it) and Catatan.
 */
import Domain
import Features
import SwiftUI

struct ManualCategoryGrid: View {
    let model: ManualEntryModel
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: KiraSpacing.space2) {
                KiraLeaf(.single, size: 18)
                Text("record.manual.category").kiraFont(.headline).foregroundStyle(.ink)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            /** A plain grid, not a lazy one: every tile is laid out, so each grows with Dynamic Type. */
            Grid(horizontalSpacing: KiraSpacing.space2, verticalSpacing: 8) {
                ForEach(rows, id: \.self) { row in
                    GridRow {
                        ForEach(row, id: \.self) { category in tile(category) }
                        ForEach(row.count..<columns, id: \.self) { _ in Color.clear.gridCellUnsizedAxes(.vertical) }
                    }
                }
            }
        }
    }

    /** The categories, `columns` to a row. */
    private var rows: [[TransactionCategory]] {
        stride(from: 0, to: model.categories.count, by: columns).map {
            Array(model.categories[$0..<min($0 + columns, model.categories.count)])
        }
    }

    /**
     The board's four to a row, fewer as the text grows, so the longest name ("Transportasi") keeps
     one line: three from xxLarge, two at the first accessibility sizes, one from AX3.
     */
    private var columns: Int {
        if typeSize >= .accessibility3 { return 1 }
        if typeSize.isAccessibilitySize { return 2 }
        return typeSize >= .xxLarge ? 3 : 4
    }

    /**
     A tile: the illustration over the name, the chosen one pandan on pandan-soft. The name is the
     button VoiceOver reads; the illustration above it chooses too but stays out of the way, so the
     button's frame holds the name's text on its own background, as Apple's contrast audit reads it.
     */
    private func tile(_ category: TransactionCategory) -> some View {
        let isOn = category == model.category
        return VStack(spacing: 0) {
            Button {
                model.select(category)
            } label: {
                KiraCategoryIcon(category.tile)
            }
            .buttonStyle(.plain)
            .accessibilityHidden(true)
            Button {
                model.select(category)
            } label: {
                Text(category == .food ? "record.manual.food" : category.title)
                    .font(.caption.weight(isOn ? .bold : .medium)).kiraLineHeight(16, size: 12)
                    .foregroundStyle(isOn ? Color.pandan : .inkMuted)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isOn ? .isSelected : [])
        }
        .padding(.top, KiraSpacing.space2)
        .frame(maxWidth: .infinity)
        .background(isOn ? Color.pandanSoft : .clear, in: RoundedRectangle(cornerRadius: KiraRadius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: KiraRadius.medium).strokeBorder(isOn ? Color.pandan : .clear, lineWidth: 1.5)
        }
    }
}

struct ManualDetails: View {
    @Bindable var model: ManualEntryModel

    var body: some View {
        VStack(spacing: 0) {
            row("record.manual.name") {
                TextField(text: $model.name, prompt: Text(model.category.title).foregroundStyle(.inkMuted)) {
                    Text("record.manual.name")
                }
                /** A one-line field with a prompt drops its label view: VoiceOver would read the prompt alone. */
                .accessibilityLabel(Text("record.manual.name"))
            }
            Button {
                withAnimation(.easeOut(duration: 0.2)) { model.isPickingDay.toggle() }
            } label: {
                row("record.manual.date") {
                    HStack {
                        Text(model.day, format: .kiraWeekdayDate).frame(maxWidth: .infinity, alignment: .leading)
                        KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted)
                            .rotationEffect(.degrees(model.isPickingDay ? 90 : 0))
                    }
                }
            }
            .buttonStyle(.plain)
            if model.isPickingDay {
                DatePicker(selection: $model.day, in: ...Date.distantFuture, displayedComponents: .date) {
                    Text("record.manual.date")
                }
                .datePickerStyle(.graphical)
                .tint(.pandan)
            }
            row("record.manual.note", isLast: true) {
                TextField(text: $model.note, prompt: Text("record.manual.optional").foregroundStyle(.inkMuted)) {
                    Text("record.manual.note")
                }
                .accessibilityLabel(Text("record.manual.note"))
            }
        }
        .padding(.horizontal, KiraSpacing.space4)
        .kiraCard(.surfaceRaised, cornerRadius: KiraRadius.large)
    }

    /** A row of the card, with the `line` rule under it unless it is the last. */
    private func row(_ label: LocalizedStringResource, isLast: Bool = false, @ViewBuilder value: () -> some View)
        -> some View
    {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.footnote.weight(.medium)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            value().font(.body).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, KiraSpacing.space3)
        .overlay(alignment: .bottom) { if !isLast { Rectangle().fill(.line).frame(height: 1) } }
        .contentShape(Rectangle())
    }
}
