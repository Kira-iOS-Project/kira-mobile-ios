/**
 Tag (design system): a small status label with a hairline, in Title Case (prepositions such as
 "dari", "di", "ke", "dan", "untuk" stay lowercase). It sits under the main text, left-aligned, or
 in a card's top-right corner when the status belongs to the whole card; never on the right of a
 row whose text can be long.
 */
import SwiftUI

/** A small status label. */
struct KiraTag: View {
    /** What the status means. */
    enum Tone: CaseIterable {
        /** Neutral (default). */
        case neutral
        /** Verified, active. */
        case pandan
        /** Soon, needs attention. */
        case turmeric
        /** Paid off, reached. */
        case healthy
        /** Past due. */
        case vulnerable
        /** Kira Peduli only. */
        case emergency
        /** On the hero card. */
        case hero
    }

    private let title: LocalizedStringResource
    private let tone: Tone
    private let icon: KiraIconName?
    @Environment(\.dynamicTypeSize) private var typeSize

    init(_ title: LocalizedStringResource, tone: Tone = .neutral, icon: KiraIconName? = nil) {
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
        .padding(.vertical, typeSize.isAccessibilitySize ? 3 : 0)
        .frame(minHeight: 24)
        .kiraCard(colors.fill, border: colors.border, cornerRadius: KiraRadius.full)
        /** One line (`white-space: nowrap`); at the accessibility sizes it wraps within its card. */
        .fixedSize(horizontal: !typeSize.isAccessibilitySize, vertical: true)
    }

    private var colors: TagColors {
        switch tone {
        case .neutral: TagColors(text: .inkMuted, fill: .surfaceMuted, border: .hairline)
        case .pandan: TagColors(text: .pandan, fill: .pandanSoft, border: .pandanLine)
        case .turmeric: TagColors(text: .coping, fill: .copingSoft, border: .copingLine)
        case .healthy: TagColors(text: .healthy, fill: .healthySoft, border: .healthyLine)
        case .vulnerable: TagColors(text: .vulnerable, fill: .vulnerableSoft, border: .vulnerableLine)
        case .emergency: TagColors(text: .emergency, fill: .emergencySoft, border: .vulnerableLine)
        case .hero: TagColors(text: .onHero, fill: .heroTrack, border: Color.white.opacity(0.2))
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
