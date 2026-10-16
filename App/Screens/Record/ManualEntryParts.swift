/**
 The parts of Catat Manual below the amount: the "Kategori" tiles, four to a row, the chosen one
 pandan on pandan-soft; and the card with Nama, Tanggal (a calendar opens under it) and Catatan.
 */
import Domain
import Features
import SwiftUI

struct ManualCategoryGrid: View {
    let model: ManualEntryModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: KiraSpacing.space2) {
                KiraLeaf(.single, size: 18)
                Text("record.manual.category").kiraFont(.headline).foregroundStyle(.ink)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: KiraSpacing.space2), count: 4), spacing: 8
            ) {
                ForEach(model.categories, id: \.self) { category in tile(category) }
            }
        }
    }

    private func tile(_ category: TransactionCategory) -> some View {
        let isOn = category == model.category
        return Button {
            model.select(category)
        } label: {
            VStack(spacing: 6) {
                KiraCategoryIcon(category.tile)
                Text(category == .food ? "record.manual.food" : category.title)
                    .font(.caption.weight(isOn ? .bold : .medium)).kiraLineHeight(16, size: 12)
                    .foregroundStyle(isOn ? Color.pandan : .inkMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity)
            .background(isOn ? Color.pandanSoft : .clear, in: RoundedRectangle(cornerRadius: KiraRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: KiraRadius.medium).strokeBorder(
                    isOn ? Color.pandan : .clear, lineWidth: 1.5)
            }
            .contentShape(RoundedRectangle(cornerRadius: KiraRadius.medium))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
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
