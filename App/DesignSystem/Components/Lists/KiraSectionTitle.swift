/**
 SectionTitle (design system): a small leaf, then the section's title in Title Case, with one
 handwritten note or one action on the right ("Lihat Semua"); the right side is never for numbers
 or badges. The note anchored here is the preferred place for a screen's one handwritten note.
 Turn the leaf off when a screen has more than three section titles.
 */
import SwiftUI

/** A section's title with an optional note or action. */
struct KiraSectionTitle: View {
    /** What sits on the right. */
    enum Trailing {
        /** Nothing (default). */
        case none
        /** A handwritten note (at most one per screen). */
        case note(LocalizedStringResource)
        /** One action, Title Case. */
        case action(LocalizedStringResource, () -> Void)
    }

    private let title: LocalizedStringResource
    private let showsLeaf: Bool
    private let trailing: Trailing
    @Environment(\.dynamicTypeSize) private var typeSize

    init(_ title: LocalizedStringResource, showsLeaf: Bool = true, trailing: Trailing = .none) {
        self.title = title
        self.showsLeaf = showsLeaf
        self.trailing = trailing
    }

    var body: some View {
        Group {
            /**
             At the accessibility text sizes the note or action goes under the title, so neither
             squeezes the other.
             */
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                    heading
                    trailingView
                }
            } else {
                HStack(spacing: KiraSpacing.space3) {
                    heading
                    Spacer(minLength: 0)
                    trailingView.fixedSize()
                }
            }
        }
        .padding(.horizontal, KiraSpacing.space1)
        .frame(minHeight: 26)
    }

    private var heading: some View {
        HStack(spacing: KiraSpacing.space2) {
            if showsLeaf { KiraLeaf(.single) }
            Text(title).font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder private var trailingView: some View {
        switch trailing {
        case .none:
            EmptyView()
        case .note(let text):
            KiraHandNote(text, size: .small, tilt: -1)
        case .action(let label, let action):
            Button(action: action) {
                Text(label)
                    .font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.pandan)
                    .padding(.horizontal, 2)
                    .frame(minHeight: KiraSize.tap)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            /** The 44 pt target overlaps the rows above and below instead of growing the title. */
            .padding(.vertical, -9)
        }
    }
}

#if DEBUG
    #Preview { GalleryLists().galleryPage() }
#endif
