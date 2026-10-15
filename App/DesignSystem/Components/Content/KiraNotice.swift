/**
 Notice (design system): a label that is a feature, not a footnote (pillars Jernih and Terjaga),
 its title in Title Case. `simulasi` on every calculator, Kira Score and payoff plan ("Hanya
 Simulasi"); `edukasi` on asset-class modules and investment answers ("Edukasi, Bukan
 Rekomendasi"); `ai` on AI-written text; `privasi` and `aman` where data is asked for;
 `peringatan` for real risk (fraud, an outside link), never for bad news about the person's numbers.
 */
import SwiftUI

/** A required label with an icon, a title and a sentence. */
struct KiraNotice: View {
    /** The notice's purpose. */
    enum Tone: CaseIterable {
        case info, simulasi, edukasi, privasi, aman, aiText, peringatan

        var icon: KiraIconName {
            switch self {
            case .info: .info
            case .simulasi: .calculator
            case .edukasi: .book
            case .privasi: .lock
            case .aman: .shield
            case .aiText: .sparkle
            case .peringatan: .alert
            }
        }
    }

    private let tone: Tone
    private let title: LocalizedStringResource?
    private let message: LocalizedStringResource?
    private let icon: KiraIconName?

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
                    Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.ink)
                }
                if let message {
                    Text(message).font(.footnote).foregroundStyle(.inkMuted)
                }
            }
            .padding(.top, 1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .kiraCard(colors.fill, border: colors.border, cornerRadius: KiraRadius.medium)
        .accessibilityElement(children: .combine)
    }

    private var colors: NoticeColors {
        switch tone {
        case .info, .edukasi:
            NoticeColors(fill: .surfaceRaised, border: .hairline, iconFill: .iluLangitMuda, icon: .iluLangitTua)
        case .aiText:
            NoticeColors(fill: .surfaceRaised, border: .hairline, iconFill: .pandanSoft, icon: .pandan)
        case .simulasi:
            NoticeColors(fill: .bertahanSoft, border: .bertahanLine, iconFill: .surfaceRaised, icon: .bertahan)
        case .privasi, .aman:
            NoticeColors(fill: .pandanSoft, border: .pandanLine, iconFill: .surfaceRaised, icon: .pandan)
        case .peringatan:
            NoticeColors(fill: .rentanSoft, border: .rentanLine, iconFill: .surfaceRaised, icon: .rentan)
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
