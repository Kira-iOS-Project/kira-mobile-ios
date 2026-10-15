// Avatar (design system): a person's initials in a soft circle, for the profile and community
// admins. Never Kira: Kira's replies carry Kuku's face with the AI sparkle (KiraChatBubble). No
// photos in the MVP. The initials are data, shown as given.
import SwiftUI

/// A person's initials in a soft circle.
struct KiraAvatar: View {
    /// The circle's soft colour.
    enum Tone: CaseIterable {
        case kunyit, hijau, langit, persik

        var fill: Color {
            switch self {
            case .kunyit: .iluKunyitMuda
            case .hijau: .iluHijauMuda
            case .langit: .iluLangitMuda
            case .persik: .iluPersikMuda
            }
        }
    }

    private let initials: String
    private let size: CGFloat
    private let tone: Tone
    private let label: LocalizedStringResource?
    /// The circle grows with Dynamic Type as the initials do, so they keep their proportions.
    @ScaledMetric private var side: CGFloat

    /// One or two letters; `label` names an avatar that stands alone, else it is hidden from VoiceOver.
    init(_ initials: String, size: CGFloat = 40, tone: Tone = .kunyit, label: LocalizedStringResource? = nil) {
        self.initials = initials
        self.size = size
        self.tone = tone
        self.label = label
        _side = ScaledMetric(wrappedValue: size, relativeTo: .body)
    }

    var body: some View {
        Text(initials)
            .font(KiraFont.display(max(13, size * 0.4), .heavy, relativeTo: .body))
            .textCase(.uppercase)
            .foregroundStyle(.ink)
            .frame(width: side, height: side)
            .background(tone.fill, in: Circle())
            .overlay { Circle().strokeBorder(.hairline, lineWidth: 1) }
            .artworkLabel(label)
    }
}

#if DEBUG
    #Preview { GalleryLabels().galleryPage() }
#endif
