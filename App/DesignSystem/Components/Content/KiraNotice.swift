/**
 Notice (design system): a label that is a feature, not a footnote (pillars Jernih and Terjaga),
 its title in Title Case. `simulation` on every calculator, Kira Score and payoff plan ("Hanya
 Simulasi"); `education` on asset-class modules and investment answers ("Edukasi, Bukan
 Rekomendasi"); `aiText` on AI-written text; `privacy` and `safe` where data is asked for;
 `warning` for real risk (fraud, an outside link), never for bad news about the person's numbers.
 */
import SwiftUI

/** A required label with an icon, a title and a sentence. */
struct KiraNotice: View {
    /** The notice's purpose. */
    enum Tone: CaseIterable {
        case info, simulation, education, privacy, safe, aiText, warning

        var icon: KiraIconName {
            switch self {
            case .info: .info
            case .simulation: .calculator
            case .education: .book
            case .privacy: .lock
            case .safe: .shield
            case .aiText: .sparkle
            case .warning: .alert
            }
        }
    }

    private let tone: Tone
    private let title: LocalizedStringResource?
    private let message: LocalizedStringResource?
    private let icon: KiraIconName?
    private var link: (title: LocalizedStringResource, action: () -> Void)?

    /** `icon` replaces the tone's own icon. */
    init(
        _ tone: Tone = .info, title: LocalizedStringResource? = nil, message: LocalizedStringResource? = nil,
        icon: KiraIconName? = nil
    ) {
        self.tone = tone
        self.title = title
        self.message = message
        self.icon = icon
    }

    var body: some View {
        HStack(alignment: .top, spacing: KiraSpacing.space3) {
            KiraIcon(icon ?? tone.icon, size: 17, weight: .semibold)
                .foregroundStyle(colors.icon)
                .frame(width: 30, height: 30)
                .background(colors.iconFill, in: Circle())
                .overlay { Circle().strokeBorder(.hairline, lineWidth: 1) }
            VStack(alignment: .leading, spacing: 2) {
                if let title {
                    Text(title).font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                        .foregroundStyle(.ink)
                }
                if let message {
                    Text(message).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
                if let link {
                    KiraLink(link.title, action: link.action).padding(.top, 2)
                }
            }
            .padding(.top, title == nil ? 0 : 1)
            /**
             A message alone is as tall as the icon at least, centred on it: one line sat 5 pt above the
             icon's middle (Portofolio Manual's "Kira tidak terhubung ke akun investasimu."). Longer
             text grows past 30 pt and starts at the top as before.
             */
            .frame(maxWidth: .infinity, minHeight: title == nil ? 30 : nil, alignment: .leading)
        }
        /** `.k-notice`'s 12 and 14 pt inside its 1 pt border, which CSS lays out and kiraCard draws over. */
        .padding(.vertical, 13)
        .padding(.horizontal, 15)
        .kiraCard(colors.fill, border: colors.border, cornerRadius: KiraRadius.medium)
        /** A notice with a link keeps the link its own element, so VoiceOver can activate it. */
        .accessibilityElement(children: link == nil ? .combine : .contain)
    }

    /** The same notice with a text link under its sentence (`.k-link` inside the notice). */
    func link(_ title: LocalizedStringResource, action: @escaping () -> Void) -> Self {
        var copy = self
        copy.link = (title, action)
        return copy
    }

    private var colors: NoticeColors {
        switch tone {
        case .info, .education:
            NoticeColors(fill: .surfaceRaised, border: .hairline, iconFill: .artSkyLight, icon: .artSkyDark)
        case .aiText:
            NoticeColors(fill: .surfaceRaised, border: .hairline, iconFill: .pandanSoft, icon: .pandan)
        case .simulation:
            NoticeColors(fill: .copingSoft, border: .copingLine, iconFill: .surfaceRaised, icon: .coping)
        case .privacy, .safe:
            NoticeColors(fill: .pandanSoft, border: .pandanLine, iconFill: .surfaceRaised, icon: .pandan)
        case .warning:
            NoticeColors(fill: .vulnerableSoft, border: .vulnerableLine, iconFill: .surfaceRaised, icon: .vulnerable)
        }
    }
}

private struct NoticeColors {
    let fill: Color
    let border: Color
    let iconFill: Color
    let icon: Color
}

#if DEBUG
    #Preview { GalleryLabels().galleryPage() }
#endif
