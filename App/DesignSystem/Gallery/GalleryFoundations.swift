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
        Swatch(name: "hero-accent", color: .heroAccent), Swatch(name: "hero-nature", color: .heroNature),
        Swatch(name: "hero-nature-2", color: .heroNature2), Swatch(name: "healthy", color: .healthy),
        Swatch(name: "healthy-soft", color: .healthySoft), Swatch(name: "healthy-line", color: .healthyLine),
        Swatch(name: "coping", color: .coping), Swatch(name: "coping-soft", color: .copingSoft),
        Swatch(name: "coping-line", color: .copingLine), Swatch(name: "vulnerable", color: .vulnerable),
        Swatch(name: "vulnerable-soft", color: .vulnerableSoft),
        Swatch(name: "vulnerable-line", color: .vulnerableLine),
        Swatch(name: "emergency", color: .emergency), Swatch(name: "emergency-soft", color: .emergencySoft),
        Swatch(name: "on-emergency", color: .onEmergency), Swatch(name: "glass", color: .glass),
        Swatch(name: "scrim", color: .scrim), Swatch(name: "art-green", color: .artGreen),
        Swatch(name: "art-green-dark", color: .artGreenDark), Swatch(name: "art-green-light", color: .artGreenLight),
        Swatch(name: "art-green-soft", color: .artGreenSoft), Swatch(name: "art-turmeric", color: .artTurmeric),
        Swatch(name: "art-turmeric-dark", color: .artTurmericDark),
        Swatch(name: "art-turmeric-light", color: .artTurmericLight),
        Swatch(name: "art-peach", color: .artPeach), Swatch(name: "art-peach-light", color: .artPeachLight),
        Swatch(name: "art-brick", color: .artBrick), Swatch(name: "art-soil", color: .artSoil),
        Swatch(name: "art-soil-dark", color: .artSoilDark), Swatch(name: "art-sky", color: .artSky),
        Swatch(name: "art-sky-dark", color: .artSkyDark), Swatch(name: "art-sky-light", color: .artSkyLight),
        Swatch(name: "art-white", color: .artWhite), Swatch(name: "art-ink", color: .artInk),
        Swatch(name: "art-gleam", color: .artGleam), Swatch(name: "art-feather", color: .artFeather),
        Swatch(name: "art-feather-dark", color: .artFeatherDark), Swatch(name: "art-mask", color: .artMask),
        Swatch(name: "art-cream", color: .artCream), Swatch(name: "art-eye", color: .artEye),
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
