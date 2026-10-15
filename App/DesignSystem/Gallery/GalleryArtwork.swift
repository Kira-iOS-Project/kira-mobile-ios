// Gallery pages for the artwork: icons, the logo and Kuku, category tiles, illustrations, leaves,
// sceneries and handwritten notes. Asset names are identifiers, shown as data.
#if DEBUG
    import SwiftUI

    extension KiraTextStyle {
        /// The design system's name for the style.
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

        /// The design system's sample for the style.
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

    /// Every icon, outline and filled.
    struct GalleryIcons: View {
        var body: some View {
            GallerySection(title: "gallery.section.icons") {
                VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                    ForEach(KiraIconName.allCases, id: \.self) { name in
                        HStack(spacing: KiraSpacing.space3) {
                            KiraIcon(name).foregroundStyle(.ink)
                            KiraIcon(name, isFilled: true).foregroundStyle(.pandan)
                            Text(name.rawValue).font(.footnote).foregroundStyle(.ink)
                        }
                    }
                }
            }
        }
    }

    /// The logo's forms and tones, and Kuku's expressions.
    struct GalleryBrand: View {
        var body: some View {
            GallerySection(title: "gallery.section.logo") {
                HStack(spacing: KiraSpacing.space4) {
                    KiraLogo()
                    KiraLogo(.mark, tone: .mono, size: 40).foregroundStyle(.ink)
                    KiraLogo(.icon, size: 56)
                    KiraLogo(.mark, tone: .hero, size: 40).padding(KiraSpacing.space2).background(.hero, in: Circle())
                }
                KiraLogo(.wordmark, size: 32)
                KiraLogo(.wordmark, tone: .hero, size: 28)
                    .padding(KiraSpacing.space4)
                    .kiraCard(.hero, cornerRadius: KiraRadius.extraLarge)
            }
            GallerySection(title: "gallery.section.mascot") {
                HStack(spacing: KiraSpacing.space3) {
                    ForEach(KiraMascot.Expression.allCases, id: \.self) { expression in
                        KiraMascot(expression, size: 104)
                    }
                }
                HStack(spacing: KiraSpacing.space4) {
                    KiraMascot(.senang, size: 120, isFramed: false)
                    KiraMascot(.tenang, size: 48, crop: .face).clipShape(Circle())
                }
            }
        }
    }

    /// Every category tile, and the three standard sizes.
    struct GalleryCategories: View {
        var body: some View {
            GallerySection(title: "gallery.section.categories") {
                VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                    ForEach(KiraCategory.allCases, id: \.self) { category in
                        HStack(spacing: KiraSpacing.space3) {
                            KiraCategoryIcon(category, size: KiraSize.tile)
                            Text(category.title).font(.footnote).foregroundStyle(.ink)
                        }
                    }
                }
                HStack(spacing: KiraSpacing.space3) {
                    KiraCategoryIcon(.tabungan, size: 36, label: "ds.category.tabungan")
                    KiraCategoryIcon(.paylater, size: 44, label: "ds.category.paylater")
                    KiraCategoryIcon(.proteksi, size: 52, label: "ds.category.proteksi")
                    KiraCategoryIcon(.makan, size: 26, isRound: true, label: "ds.category.makan")
                }
            }
        }
    }

    /// Every spot illustration.
    struct GalleryIllustrations: View {
        var body: some View {
            GallerySection(title: "gallery.section.illustrations") {
                VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                    ForEach(KiraIllustrationName.allCases, id: \.self) { name in
                        HStack(spacing: KiraSpacing.space3) {
                            KiraIllustration(name, size: 84)
                            Text(name.rawValue).font(.footnote).foregroundStyle(.ink)
                        }
                    }
                }
                KiraIllustration(.mekar, size: 120, label: "gallery.illustration.mekar")
            }
        }
    }

    #Preview { GalleryBrand().galleryPage() }
#endif
