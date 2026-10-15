// Tag (design system): a small status label with a hairline, in Title Case (prepositions such as
// "dari", "di", "ke", "dan", "untuk" stay lowercase). It sits under the main text, left-aligned, or
// in a card's top-right corner when the status belongs to the whole card; never on the right of a
// row whose text can be long.
import SwiftUI

/// A small status label.
struct KiraTag: View {
    /// What the status means.
    enum Tone: CaseIterable {
        /// Neutral (default).
        case netral
        /// Verified, active.
        case pandan
        /// Soon, needs attention.
        case kunyit
        /// Paid off, reached.
        case sehat
        /// Past due.
        case rentan
        /// Kira Peduli only.
        case darurat
        /// On the hero card.
        case hero
    }

    private let title: LocalizedStringResource
    private let tone: Tone
    private let icon: KiraIconName?

    init(_ title: LocalizedStringResource, tone: Tone = .netral, icon: KiraIconName? = nil) {
        self.title = title
        self.tone = tone
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon { KiraIcon(icon, size: 13, weight: .bold) }
            Text(title)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(colors.text)
        .padding(.horizontal, 9)
        .frame(minHeight: 24)
        .kiraCard(colors.fill, border: colors.border, cornerRadius: KiraRadius.full)
        .fixedSize()
    }

    private var colors: TagColors {
        switch tone {
        case .netral: TagColors(text: .inkMuted, fill: .surfaceMuted, border: .hairline)
        case .pandan: TagColors(text: .pandan, fill: .pandanSoft, border: .pandanLine)
        case .kunyit: TagColors(text: .bertahan, fill: .bertahanSoft, border: .bertahanLine)
        case .sehat: TagColors(text: .sehat, fill: .sehatSoft, border: .sehatLine)
        case .rentan: TagColors(text: .rentan, fill: .rentanSoft, border: .rentanLine)
        case .darurat: TagColors(text: .darurat, fill: .daruratSoft, border: .rentanLine)
        case .hero: TagColors(text: .onHero, fill: .heroTrack, border: Color.onHero.opacity(0.2))
        }
    }
}

private struct TagColors {
    let text: Color
    let fill: Color
    let border: Color
}

#if DEBUG
    #Preview { GalleryLabels().galleryPage() }
#endif
