// DraftCard (design system): transactions AI read from a chat, a receipt or a screenshot, waiting
// to be confirmed. The dashed border means "not saved yet" and is used for nothing else; once saved,
// it becomes an ordinary hairline card. The biggest thing is the most important: the total on top,
// then per row name → amount → category, never amount and category side by side. No wallet names.
// The pencil on each row is the only way to edit, so under the list there is one primary
// "Simpan N Transaksi"; `.secondary` adds an optional action on its left ("Lanjut Chat"), and both
// then shrink to 44 pt to share the row. The total comes from the screen model.
import SwiftUI

/// A draft transaction read by AI.
struct KiraDraftItem: Identifiable {
    let label: Text
    let amount: Decimal
    let category: KiraCategory
    var categoryName: Text?
    /// How Kira read slang, such as "goceng" read as Rp5.000,00.
    var note: Text?
    let id = UUID()
}

/// Unsaved transactions with their total and one Save button.
struct KiraDraftCard: View {
    private let items: [KiraDraftItem]
    private let total: Decimal
    private let onSave: () -> Void
    private let onEdit: (KiraDraftItem) -> Void
    private var eyebrowText: LocalizedStringResource = "ds.draft.eyebrow"
    private var saveText: LocalizedStringResource?
    private var secondaryText: LocalizedStringResource?
    private var onSecondary: (() -> Void)?

    init(
        items: [KiraDraftItem], total: Decimal, onSave: @escaping () -> Void,
        onEdit: @escaping (KiraDraftItem) -> Void
    ) {
        self.items = items
        self.total = total
        self.onSave = onSave
        self.onEdit = onEdit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            VStack(alignment: .leading, spacing: 2) {
                Text(eyebrowText).kiraFont(.overline).padding(.bottom, 6)
                Text("ds.draft.count \(items.count)").font(.footnote.weight(.medium))
                KiraAmount(total, size: .large)
            }
            .foregroundStyle(.inkMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, KiraSpacing.space3)
            .overlay(alignment: .bottom) { Rectangle().fill(.line).frame(height: 1) }
            ForEach(items) { item in row(item) }
            actions
        }
        .padding(KiraSpacing.space4)
        .background(.surfaceRaised, in: RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous)
                .strokeBorder(.lineStrong, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("ds.draft.label"))
    }

    private func row(_ item: KiraDraftItem) -> some View {
        HStack(alignment: .top, spacing: KiraSpacing.space3) {
            KiraCategoryIcon(item.category, size: KiraSize.tile)
            VStack(alignment: .leading, spacing: 1) {
                item.label.font(.subheadline.weight(.semibold)).foregroundStyle(.ink)
                KiraAmount(item.amount, size: .medium)
                if let name = item.categoryName { name.font(.footnote).foregroundStyle(.inkMuted) }
                if let note = item.note { note.font(.footnote.weight(.medium)).foregroundStyle(.pandan) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            Button {
                onEdit(item)
            } label: {
                KiraIcon(.pencil, size: 18)
                    .foregroundStyle(.inkMuted)
                    .frame(width: KiraSize.tap, height: KiraSize.tap)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("ds.draft.edit \(item.label)"))
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Rectangle().fill(.line).frame(height: 1) }
    }

    @ViewBuilder private var actions: some View {
        let save = KiraButton(saveText ?? "ds.draft.save \(items.count)", size: onSecondary == nil ? .medium : .small) {
            onSave()
        }
        if let secondaryText, let onSecondary {
            HStack(spacing: KiraSpacing.space2) {
                KiraButton(secondaryText, variant: .secondary, size: .small, action: onSecondary)
                save.block()
            }
        } else {
            save.block()
        }
    }

    /// The same card with another eyebrow than "Draf · belum disimpan".
    func eyebrow(_ text: LocalizedStringResource) -> Self { copy { $0.eyebrowText = text } }

    /// The same card with another save label than "Simpan N Transaksi".
    func saveLabel(_ text: LocalizedStringResource) -> Self { copy { $0.saveText = text } }

    /// The same card with a secondary action on the left of Save ("Lanjut Chat"); never an edit.
    func secondary(_ label: LocalizedStringResource, action: @escaping () -> Void) -> Self {
        copy {
            $0.secondaryText = label
            $0.onSecondary = action
        }
    }

    private func copy(_ change: (inout Self) -> Void) -> Self {
        var card = self
        change(&card)
        return card
    }
}

#if DEBUG
    #Preview { GalleryChat().galleryPage() }
#endif
