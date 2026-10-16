/**
 Gallery pages for the foundations: every colour token, every text style, the spacing and radius
 scales. Token and style names are identifiers, shown as data.
 */
#if DEBUG
    import SwiftUI

    private struct Swatch: Identifiable {
        let name: String
        let color: Color
        var id: String { name }
    }

    private let swatches: [Swatch] = [
        Swatch(name: "surface", color: .surface), Swatch(name: "surface-raised", color: .surfaceRaised),
        Swatch(name: "surface-muted", color: .surfaceMuted), Swatch(name: "button", color: .button),
        Swatch(name: "button-line", color: .buttonLine), Swatch(name: "track", color: .track),
        Swatch(name: "line", color: .line), Swatch(name: "hairline", color: .hairline),
        Swatch(name: "line-strong", color: .lineStrong), Swatch(name: "ink", color: .ink),
        Swatch(name: "ink-muted", color: .inkMuted), Swatch(name: "pandan", color: .pandan),
        Swatch(name: "pandan-strong", color: .pandanStrong), Swatch(name: "pandan-soft", color: .pandanSoft),
        Swatch(name: "pandan-line", color: .pandanLine), Swatch(name: "on-pandan", color: .onPandan),
        Swatch(name: "hero", color: .hero), Swatch(name: "on-hero", color: .onHero),
        Swatch(name: "on-hero-muted", color: .onHeroMuted), Swatch(name: "hero-track", color: .heroTrack),
        Swatch(name: "hero-accent", color: .heroAccent), Swatch(name: "hero-alam", color: .heroAlam),
        Swatch(name: "hero-alam-2", color: .heroAlam2), Swatch(name: "sehat", color: .sehat),
        Swatch(name: "sehat-soft", color: .sehatSoft), Swatch(name: "sehat-line", color: .sehatLine),
        Swatch(name: "bertahan", color: .bertahan), Swatch(name: "bertahan-soft", color: .bertahanSoft),
        Swatch(name: "bertahan-line", color: .bertahanLine), Swatch(name: "rentan", color: .rentan),
        Swatch(name: "rentan-soft", color: .rentanSoft), Swatch(name: "rentan-line", color: .rentanLine),
        Swatch(name: "darurat", color: .darurat), Swatch(name: "darurat-soft", color: .daruratSoft),
        Swatch(name: "on-darurat", color: .onDarurat), Swatch(name: "glass", color: .glass),
        Swatch(name: "scrim", color: .scrim), Swatch(name: "ilu-hijau", color: .iluHijau),
        Swatch(name: "ilu-hijau-tua", color: .iluHijauTua), Swatch(name: "ilu-hijau-muda", color: .iluHijauMuda),
        Swatch(name: "ilu-hijau-lembut", color: .iluHijauLembut), Swatch(name: "ilu-kunyit", color: .iluKunyit),
        Swatch(name: "ilu-kunyit-tua", color: .iluKunyitTua), Swatch(name: "ilu-kunyit-muda", color: .iluKunyitMuda),
        Swatch(name: "ilu-persik", color: .iluPersik), Swatch(name: "ilu-persik-muda", color: .iluPersikMuda),
        Swatch(name: "ilu-bata", color: .iluBata), Swatch(name: "ilu-tanah", color: .iluTanah),
        Swatch(name: "ilu-tanah-tua", color: .iluTanahTua), Swatch(name: "ilu-langit", color: .iluLangit),
        Swatch(name: "ilu-langit-tua", color: .iluLangitTua), Swatch(name: "ilu-langit-muda", color: .iluLangitMuda),
        Swatch(name: "ilu-putih", color: .iluPutih), Swatch(name: "ilu-tinta", color: .iluTinta),
        Swatch(name: "ilu-kilau", color: .iluKilau), Swatch(name: "ilu-bulu", color: .iluBulu),
        Swatch(name: "ilu-bulu-tua", color: .iluBuluTua), Swatch(name: "ilu-topeng", color: .iluTopeng),
        Swatch(name: "ilu-krem", color: .iluKrem), Swatch(name: "ilu-mata", color: .iluMata),
    ]

    /** Every colour token, light or dark with the device. */
    struct GalleryColors: View {
        var body: some View {
            GallerySection(title: "gallery.section.colors") {
                VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                    ForEach(swatches) { swatch in
                        HStack(spacing: KiraSpacing.space3) {
                            RoundedRectangle(cornerRadius: KiraRadius.small, style: .continuous)
                                .fill(swatch.color)
                                .frame(width: 40, height: 40)
                                .hairline(cornerRadius: KiraRadius.small)
                            Text(swatch.name).font(.footnote).foregroundStyle(.ink)
                        }
                    }
                }
            }
        }
    }

    /** Every text style with its sample. */
    struct GalleryType: View {
        var body: some View {
            GallerySection(title: "gallery.section.type") {
                ForEach(KiraTextStyle.allCases, id: \.self) { style in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(style.galleryName).font(.caption).foregroundStyle(.inkMuted)
                        Text(style.gallerySample).kiraFont(style).foregroundStyle(.ink)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            GallerySection(title: "gallery.section.spacing") {
                ForEach(GalleryMetric.spacing) { metric in
                    HStack(spacing: KiraSpacing.space3) {
                        Text(metric.name).font(.caption).foregroundStyle(.inkMuted).frame(
                            width: 72, alignment: .leading)
                        Capsule().fill(.pandan).frame(width: metric.value, height: 8)
                    }
                }
            }
            GallerySection(title: "gallery.section.radius") {
                HStack(spacing: KiraSpacing.space3) {
                    ForEach(GalleryMetric.radius) { metric in
                        VStack(spacing: KiraSpacing.space1) {
                            RoundedRectangle(cornerRadius: metric.value, style: .continuous)
                                .fill(.surfaceRaised)
                                .hairline(cornerRadius: metric.value)
                                .frame(width: 52, height: 52)
                            Text(metric.name).font(.caption).foregroundStyle(.inkMuted)
                        }
                    }
                }
            }
        }
    }

    /** One step of a scale, named as the design system names it. */
    private struct GalleryMetric: Identifiable {
        let name: String
        let value: CGFloat
        var id: String { name }

        static let spacing = [
            GalleryMetric(name: "space-1", value: KiraSpacing.space1),
            GalleryMetric(name: "space-2", value: KiraSpacing.space2),
            GalleryMetric(name: "space-3", value: KiraSpacing.space3),
            GalleryMetric(name: "space-4", value: KiraSpacing.space4),
            GalleryMetric(name: "space-5", value: KiraSpacing.space5),
            GalleryMetric(name: "space-6", value: KiraSpacing.space6),
            GalleryMetric(name: "space-8", value: KiraSpacing.space8),
            GalleryMetric(name: "space-10", value: KiraSpacing.space10),
            GalleryMetric(name: "screen", value: KiraSpacing.screen),
            GalleryMetric(name: "size-tap", value: KiraSize.tap),
            GalleryMetric(name: "size-icon", value: KiraSize.icon),
            GalleryMetric(name: "size-tile", value: KiraSize.tile),
        ]
        static let radius = [
            GalleryMetric(name: "xs", value: KiraRadius.extraSmall), GalleryMetric(name: "sm", value: KiraRadius.small),
            GalleryMetric(name: "md", value: KiraRadius.medium), GalleryMetric(name: "lg", value: KiraRadius.large),
            GalleryMetric(name: "xl", value: KiraRadius.extraLarge),
        ]
    }

    #Preview { GalleryColors().galleryPage() }
    #Preview { GalleryType().galleryPage() }
#endif
