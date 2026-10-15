// BandPill (design system): the Kira Score band as a pill carrying colour, word, glyph and a thin
// border of its own colour at once. The score engine decides the band (a consumptive debt at 0 caps
// the band at Rentan), so pass the band it sends, or `Score(...).band`.
import Domain
import SwiftUI

/// A Kira Score band: Sehat, Bertahan or Rentan.
struct KiraBandPill: View {
    /// The pill's size.
    enum Size: CaseIterable {
        /// 28 pt (default).
        case medium
        /// 22 pt, inside rows.
        case small
    }

    private let band: ScoreBand
    private let size: Size

    init(_ band: ScoreBand, size: Size = .medium) {
        self.band = band
        self.size = size
    }

    var body: some View {
        HStack(spacing: size == .medium ? 6 : 5) {
            BandGlyph(band: band)
            Text(band.title)
        }
        .font(size == .medium ? .footnote.weight(.semibold) : .caption.weight(.semibold))
        .foregroundStyle(band.color)
        .padding(.leading, size == .medium ? 9 : 6)
        .padding(.trailing, size == .medium ? KiraSpacing.space3 : KiraSpacing.space2)
        .frame(minHeight: size == .medium ? 28 : 22)
        .kiraCard(band.softColor, border: band.lineColor, cornerRadius: KiraRadius.full)
        .fixedSize()
    }
}

#if DEBUG
    #Preview { GalleryScore().galleryPage() }
#endif
