/**
 Gallery pages for the artwork: icons, the logo and Kuku, category tiles, illustrations, leaves,
 sceneries and handwritten notes. Asset names are identifiers, shown as data.
 */
#if DEBUG
    import SwiftUI

    extension KiraTextStyle {
        /** The design system's name for the style. */
        var galleryName: String {
            switch self {
            case .score: "t-score"
            case .amountXL: "t-amount-xl"
            case .largeTitle: "t-large-title"
            case .title: "t-title"
            case .amount: "t-amount"
            case .headline: "t-headline"
            case .body: "t-body"
            case .callout: "t-callout"
            case .footnote: "t-footnote"
            case .caption: "t-caption"
            case .overline: "t-overline"
            case .formula: "t-formula"
            case .hand: "t-hand"
            case .handSmall: "t-hand-sm"
            }
        }

        /** The design system's sample for the style. */
        var gallerySample: LocalizedStringResource {
            switch self {
            case .score: "gallery.type.score"
            case .amountXL: "gallery.type.amountXL"
            case .largeTitle: "gallery.type.largeTitle"
            case .title: "gallery.type.title"
            case .amount: "gallery.type.amount"
            case .headline: "gallery.type.headline"
            case .body: "gallery.type.body"
            case .callout: "gallery.type.callout"
            case .footnote: "gallery.type.footnote"
            case .caption: "gallery.type.caption"
            case .overline: "gallery.type.overline"
            case .formula: "gallery.type.formula"
            case .hand: "gallery.type.hand"
            case .handSmall: "gallery.type.handSmall"
            }
        }
    }

    /**
     The Icon preview: every icon beside its name, the first three in pandan duotone. A list rather
     than the preview's grid, so a long name never meets a narrow column at large text sizes.
     */
    struct GalleryIcons: View {
        var body: some View {
            GallerySection(title: "gallery.section.icons") {
                VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                    ForEach(Array(KiraIconName.allCases.enumerated()), id: \.element) { index, name in
                        HStack(spacing: KiraSpacing.space3) {
                            KiraIcon(name, isFilled: index < 3)
                            Text(name.rawValue).font(.footnote)
                        }
                        .foregroundStyle(index < 3 ? Color.pandan : Color.inkMuted)
                    }
                }
            }
        }
    }

    /** The Logo and Mascot previews. */
    struct GalleryBrand: View {
        var body: some View {
            GallerySection(title: "gallery.section.logo") {
                KiraFlowRow(spacing: 20) {
                    KiraLogo(.icon, size: 96)
                    KiraLogo(.wordmark, size: 44)
                    HStack(spacing: 14) {
                        KiraLogo(.mark, tone: .hero, size: 40)
                        KiraLogo(.wordmark, tone: .hero, size: 28)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 18)
                    .background(.hero, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    KiraLogo(.mark, tone: .mono, size: 32).foregroundStyle(.ink)
                    KiraLogo()
                }
            }
            GallerySection(title: "gallery.section.mascot") {
                KiraFlowRow(spacing: KiraSpacing.space4) {
                    ForEach(KiraMascot.Expression.allCases, id: \.self) { expression in
                        KiraMascot(expression, size: 180)
                    }
                    KiraMascot(.happy, size: 120, isFramed: false)
                    KiraMascot(.calm, size: 48, crop: .face).clipShape(Circle())
                }
            }
        }
    }

    /**
     The CategoryIcon preview: every tile beside its name, then the standard sizes and the round
     tile. A list rather than the preview's grid, so a long name never meets a narrow column at
     large text sizes.
     */
    struct GalleryCategories: View {
        var body: some View {
            GallerySection(title: "gallery.section.categories") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(KiraCategory.allCases, id: \.self) { category in
                        HStack(spacing: KiraSpacing.space3) {
                            KiraCategoryIcon(category)
                            Text(category.title).font(.footnote).foregroundStyle(.inkMuted)
                        }
                    }
                }
                HStack(spacing: KiraSpacing.space3) {
                    KiraCategoryIcon(.savings, size: 36, label: "ds.category.savings")
                    KiraCategoryIcon(.paylater, size: 44, label: "ds.category.paylater")
                    KiraCategoryIcon(.protection, size: 52, label: "ds.category.protection")
                    KiraCategoryIcon(.food, size: 26, isRound: true, label: "ds.category.food")
                }
            }
        }
    }

    /**
     The Illustration preview: every illustration at 96 pt beside its name, as a list rather than
     the preview's grid for the same reason as the categories.
     */
    struct GalleryIllustrations: View {
        var body: some View {
            GallerySection(title: "gallery.section.illustrations") {
                VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                    ForEach(KiraIllustrationName.allCases, id: \.self) { name in
                        HStack(spacing: KiraSpacing.space3) {
                            KiraIllustration(name, size: 96)
                            Text(name.rawValue).font(.footnote).foregroundStyle(.inkMuted)
                        }
                    }
                }
                KiraIllustration(.bloom, size: 120, label: "gallery.illustration.bloom")
            }
        }
    }

    #Preview { GalleryBrand().galleryPage() }
#endif
