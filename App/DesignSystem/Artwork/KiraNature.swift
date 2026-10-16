/**
 Leaf and Scenery (design system): Kira's small garden. Always decorative and hidden from
 VoiceOver; never behind a number or small text. One scenery per screen.
   Leaf: `twig` (a sprig, 120 pt) peeking from a screen's top corner, `pandan` (blades) in a
   card's corner, `single` (18 pt) before a section title. Tones: `nature` (illustration greens),
   `soft` (one soft green, for screen backgrounds), `hero` (tone on tone inside the hero card).
   Scenery: hills and terraced rice fields, full width; `nature` with the late sun behind a large
   title or the splash, `hero` almost invisible at the bottom of the hero card.
 */
import SwiftUI

/** A decorative leaf, sprig or pandan blades. */
struct KiraLeaf: View {
    /** The leaf's shape. */
    enum Name: String, CaseIterable {
        case single, twig, pandan
    }

    /** The leaf's colours. */
    enum Tone: String, CaseIterable {
        case nature, soft, hero
    }

    private let name: Name
    private let tone: Tone
    private let size: CGFloat?
    private let isFlipped: Bool

    /** `size` defaults to 18 pt for `single` and 120 pt for the others; `isFlipped` mirrors it. */
    init(_ name: Name, tone: Tone = .nature, size: CGFloat? = nil, isFlipped: Bool = false) {
        self.name = name
        self.tone = tone
        self.size = size
        self.isFlipped = isFlipped
    }

    var body: some View {
        let side = size ?? (name == .single ? 18 : 120)
        Image(decorative: "leaf-\(name.rawValue)-\(tone.rawValue)")
            .resizable()
            .frame(width: side, height: side)
            .scaleEffect(x: isFlipped ? -1 : 1)
            .accessibilityHidden(true)
    }
}

/** A full-width landscape of hills and rice terraces, anchored to its bottom edge. */
struct KiraScenery: View {
    /** The landscape's colours. */
    enum Tone: CaseIterable {
        case nature, hero
    }

    private let tone: Tone
    private let hasSun: Bool
    private let height: CGFloat

    /** `hasSun` adds the setting sun (nature only); the width always fills the container. */
    init(tone: Tone = .nature, hasSun: Bool = false, height: CGFloat = 150) {
        self.tone = tone
        self.hasSun = hasSun
        self.height = height
    }

    private var asset: String {
        switch tone {
        case .hero: "scenery-hero"
        case .nature: hasSun ? "scenery-nature-evening" : "scenery-nature"
        }
    }

    /**
     The artifact's `preserveAspectRatio="xMidYMax slice"`: the image fills the width it is given
     and is cropped, centred and held to the bottom edge. `minWidth: 0` keeps the frame at the
     container's width, as the image scaled to `height` alone is wider (400 pt at 150 pt tall).
     */
    var body: some View {
        Image(decorative: asset)
            .resizable()
            .scaledToFill()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .bottom)
            .clipped()
            .accessibilityHidden(true)
    }
}

#if DEBUG
    #Preview { GalleryNature().galleryPage() }
#endif
