/**
 CategoryIcon (design system): a small illustration on a soft tile with a hairline, for
 transactions, steps and indicator groups. 40 pt in a transaction row, 44 pt in priority steps and
 indicator group heads, 52 pt in a category list. Never a navigation icon: those are KiraIcon.
 */
import SwiftUI

/** A category's illustrated tile. */
struct KiraCategoryIcon: View {
    private let category: KiraCategory
    private let size: CGFloat
    private let isRound: Bool
    private let label: LocalizedStringResource?

    /**
     `label` names a tile that stands alone; next to its name, leave it out and the tile is hidden
     from VoiceOver. `isRound` is the chip's round tile.
     */
    init(_ category: KiraCategory, size: CGFloat = 44, isRound: Bool = false, label: LocalizedStringResource? = nil) {
        self.category = category
        self.size = size
        self.isRound = isRound
        self.label = label
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: isRound ? size / 2 : KiraRadius.small, style: .continuous)
        Image(decorative: "category-\(category.rawValue)")
            .resizable()
            .frame(width: (size * 0.8).rounded(), height: (size * 0.8).rounded())
            .frame(width: size, height: size)
            .background(category.tint, in: shape)
            .overlay { shape.strokeBorder(.hairline, lineWidth: 1) }
            .artworkLabel(label)
    }
}

#if DEBUG
    #Preview { GalleryCategories().galleryPage() }
#endif
