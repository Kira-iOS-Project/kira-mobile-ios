/**
 Chip (design system): a capsule choice for quiz answers, filters and quick categories. Selected
 is never colour alone: a pandan outline on pandan-soft, with a check mark (or the chosen leading
 icon or category tile). Quiz questions may allow several selected chips.
 */
import SwiftUI

/** A selectable capsule. */
struct KiraChip: View {
    /** What sits before the label. */
    enum Leading {
        /** Nothing; a check mark when selected (default). */
        case none
        /** A line icon. */
        case icon(KiraIconName)
        /** A round category tile. */
        case category(KiraCategory)
    }

    private let title: LocalizedStringResource
    private let isSelected: Bool
    private let leading: Leading
    private let action: () -> Void

    init(
        _ title: LocalizedStringResource, isSelected: Bool, leading: Leading = .none, action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.leading = leading
        self.action = action
    }

    var body: some View {
        HStack(spacing: 0) {
            if case .category(let category) = leading {
                /**
                 The tile is its own button, hidden from VoiceOver, so the labelled button holds
                 only text: Apple's audit measures a pastel tile inside a button as its text.
                 */
                Button(action: action) {
                    KiraCategoryIcon(category, size: 26, isRound: true)
                        .padding(.leading, 6)
                        .frame(minHeight: 40)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityHidden(true)
            }
            Button(action: action) {
                HStack(spacing: 6) {
                    leadingIcon
                    Text(title)
                }
                .padding(.leading, isCategory ? 6 : 14)
                .padding(.trailing, 14)
                .frame(minHeight: 40)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(isSelected ? Color.pandan : Color.ink)
        .kiraCard(
            isSelected ? .pandanSoft : .button, border: isSelected ? .pandan : .buttonLine,
            cornerRadius: KiraRadius.full
        )
        /** 40 pt chip, 44 pt touch target. */
        .padding(.vertical, 2)
    }

    private var isCategory: Bool {
        if case .category = leading { return true }
        return false
    }

    @ViewBuilder private var leadingIcon: some View {
        switch leading {
        case .none:
            if isSelected { KiraIcon(.check, size: 16, weight: .bold) }
        case .icon(let name):
            KiraIcon(name, size: 16, weight: .semibold)
        case .category:
            EmptyView()
        }
    }
}

#if DEBUG
    #Preview { GalleryForms().galleryPage() }
#endif
