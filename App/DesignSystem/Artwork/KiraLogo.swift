// Logo (design system): the leaf-bubble ("daun-gelembung"), a leaf that is also a chat bubble, with
// a kunyit dot for the late-afternoon sun. The marks in Assets.xcassets cut the vein out of the
// leaf, so the vein always shows what is behind it, as the design system asks. Keep half the mark's
// width clear around it; the mark is at least 16 pt, the wordmark at least 24 pt. Never Kuku in its
// place.
import SwiftUI

/// The Kira logo: the mark, the mark with "Kira", or the app icon.
struct KiraLogo: View {
    /// Which form of the logo.
    enum Variant: CaseIterable {
        /// The leaf-bubble alone (default).
        case mark
        /// The mark followed by "Kira" in Plus Jakarta Sans ExtraBold.
        case wordmark
        /// The app icon: a white leaf on the hero green.
        case icon
    }

    /// The mark's colours.
    enum Tone: CaseIterable {
        /// Pandan on light backgrounds (default).
        case pandan
        /// White on the hero green: the splash and the hero card.
        case hero
        /// One colour, the surrounding foreground, without the sun dot: print and watermarks.
        case mono
    }

    private let variant: Variant
    private let tone: Tone
    private let size: CGFloat

    /// `size` is the mark's side in points (the whole tile for `.icon`).
    init(_ variant: Variant = .mark, tone: Tone = .pandan, size: CGFloat = 40) {
        self.variant = variant
        self.tone = tone
        self.size = size
    }

    var body: some View {
        content.artworkLabel("ds.logo.name")
    }

    @ViewBuilder private var content: some View {
        switch variant {
        case .icon:
            Image(decorative: "logo-ikon").resizable().frame(width: size, height: size)
        case .mark:
            mark
        case .wordmark:
            HStack(spacing: size * 0.24) {
                mark
                Wordmark(size: size * 0.92, color: tone == .hero ? .onHero : .ink)
            }
        }
    }

    private var mark: some View {
        markImage.resizable().frame(width: size, height: size)
    }

    private var markImage: Image {
        switch tone {
        case .pandan: Image(decorative: "logo-tanda")
        case .hero: Image(decorative: "logo-tanda-hero")
        case .mono: Image(decorative: "logo-tanda-mono")
        }
    }
}

/// "Kira" in Plus Jakarta Sans ExtraBold, drawn as part of the logo image: a canvas paints the word
/// at a fixed size, so the logo keeps its proportions and VoiceOver reads only the logo's name.
private struct Wordmark: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        word.hidden().overlay {
            Canvas { context, canvas in
                context.draw(context.resolve(word), in: CGRect(origin: .zero, size: canvas))
            }
        }
    }

    private var word: Text {
        Text("ds.logo.name").font(KiraFont.brand(size)).tracking(-0.035 * size).foregroundStyle(color)
    }
}

#if DEBUG
    #Preview { GalleryBrand().galleryPage() }
#endif
