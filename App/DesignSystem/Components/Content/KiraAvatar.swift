/**
 Avatar (design system): a person's initials in a soft circle, for the profile and community
 admins. Never Kira: Kira's replies carry Kuku's face with the AI sparkle (KiraChatBubble). No
 photos in the MVP. The initials are data, shown as given.
 */
import SwiftUI

/** A person's initials in a soft circle. */
struct KiraAvatar: View {
    /** The circle's soft colour. */
    enum Tone: CaseIterable {
        case turmeric, green, sky, peach

        var fill: Color {
            switch self {
            case .turmeric: .artTurmericLight
            case .green: .artGreenLight
            case .sky: .artSkyLight
            case .peach: .artPeachLight
            }
        }
    }

    private let initials: String
    private let size: CGFloat
    private let tone: Tone
    private let label: LocalizedStringResource?
    /** The circle grows with Dynamic Type as the initials do, so they keep their proportions. */
    @ScaledMetric private var side: CGFloat

    /** One or two letters; `label` names an avatar that stands alone, else it is hidden from VoiceOver. */
    init(_ initials: String, size: CGFloat = 40, tone: Tone = .turmeric, label: LocalizedStringResource? = nil) {
        self.initials = initials
        self.size = size
        self.tone = tone
        self.label = label
        _side = ScaledMetric(wrappedValue: size, relativeTo: .body)
    }

    /** The initials are 40% of the circle, as the design system draws them. */
    private var initialsSize: CGFloat { (size * 0.4).rounded() }

    var body: some View {
        Text(initials)
            .font(KiraFont.display(initialsSize, .heavy, relativeTo: .body))
            .textCase(.uppercase)
            .foregroundStyle(.ink)
            .frame(width: side, height: side)
            .background(tone.fill, in: Circle())
            .overlay { Circle().strokeBorder(.hairline, lineWidth: 1) }
            .artworkLabel(label)
            /**
             Below 12 pt (an avatar under 30 pt, such as Etalase's 26 pt seller) the initials are one
             of the design system's small sizes.
             */
            .kiraSmallType(initialsSize < 12)
    }
}

#if DEBUG
    #Preview { GalleryLabels().galleryPage() }
#endif
