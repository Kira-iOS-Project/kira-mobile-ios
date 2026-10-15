// The design system gallery: every component on one page per group, for review against the design
// system artifact. Debug builds only: launch with `-KiraGallery` (the Kira scheme lists it, off; tick
// it under Run › Arguments), or open any component's preview, which shows its gallery page.
#if DEBUG
    import SwiftUI

    /// The gallery's pages.
    enum GalleryPage: String, CaseIterable, Hashable {
        case colors, type, icons, brand, categories, illustrations, nature, buttons, forms, labels, amounts
        case progress, score, lists, navigation, chat

        var title: LocalizedStringResource {
            switch self {
            case .colors: "gallery.page.colors"
            case .type: "gallery.page.type"
            case .icons: "gallery.page.icons"
            case .brand: "gallery.page.brand"
            case .categories: "gallery.page.categories"
            case .illustrations: "gallery.page.illustrations"
            case .nature: "gallery.page.nature"
            case .buttons: "gallery.page.buttons"
            case .forms: "gallery.page.forms"
            case .labels: "gallery.page.labels"
            case .amounts: "gallery.page.amounts"
            case .progress: "gallery.page.progress"
            case .score: "gallery.page.score"
            case .lists: "gallery.page.lists"
            case .navigation: "gallery.page.navigation"
            case .chat: "gallery.page.chat"
            }
        }

        @ViewBuilder var content: some View {
            switch self {
            case .colors: GalleryColors()
            case .type: GalleryType()
            case .icons: GalleryIcons()
            case .brand: GalleryBrand()
            case .categories: GalleryCategories()
            case .illustrations: GalleryIllustrations()
            case .nature: GalleryNature()
            case .buttons: GalleryButtons()
            case .forms: GalleryForms()
            case .labels: GalleryLabels()
            case .amounts: GalleryAmounts()
            case .progress: GalleryProgress()
            case .score: GalleryScore()
            case .lists: GalleryLists()
            case .navigation: GalleryNavigation()
            case .chat: GalleryChat()
            }
        }
    }

    /// The gallery's first screen: the list of pages, or one page when the launch names it.
    struct DesignSystemGallery: View {
        private let page: GalleryPage?
        @State private var path: [GalleryPage] = []

        init(page: GalleryPage? = nil) {
            self.page = page
        }

        /// The gallery when the launch arguments hold `-KiraGallery`, opened on the page named after
        /// it (`-KiraGallery colors`), else nil.
        init?(arguments: [String]) {
            guard let index = arguments.firstIndex(of: "-KiraGallery") else { return nil }
            self.init(page: arguments.dropFirst(index + 1).first.flatMap(GalleryPage.init(rawValue:)))
        }

        var body: some View {
            NavigationStack(path: $path) {
                Group {
                    if let page { GalleryPageView(page: page) } else { pageList }
                }
                .navigationDestination(for: GalleryPage.self) { page in
                    GalleryPageView(page: page)
                }
            }
        }

        private var pageList: some View {
            VStack(alignment: .leading, spacing: KiraSpacing.space6) {
                KiraNavBar("gallery.title", isLarge: true).eyebrow("gallery.eyebrow")
                KiraListGroup("gallery.pages") {
                    ForEach(GalleryPage.allCases, id: \.self) { page in
                        KiraListRow(Text(page.title), action: { path.append(page) })
                    }
                }
            }
            .padding(.bottom, 1200)
            .galleryPage()
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    /// One gallery page under its nav bar.
    private struct GalleryPageView: View {
        let page: GalleryPage
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            VStack(alignment: .leading, spacing: KiraSpacing.space6) {
                KiraNavBar(page.title, leading: .back("gallery.back") { dismiss() })
                page.content
            }
            // Room after the content, so the audit test's scrolls never pull past the end: a page
            // that bounces back leaves stale accessibility frames, and the audit then measures the
            // wrong pixels. The page list has the same room.
            .padding(.bottom, 1200)
            .galleryPage()
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    /// A titled block of a gallery page.
    struct GallerySection<Content: View>: View {
        let title: LocalizedStringResource
        @ViewBuilder let content: Content

        var body: some View {
            VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                Text(title).kiraFont(.overline).foregroundStyle(.inkMuted).accessibilityAddTraits(.isHeader)
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    extension View {
        /// A gallery page, in the gallery and in previews: scrolling on the screen background.
        func galleryPage() -> some View {
            ScrollView { self.padding(KiraSpacing.screen) }
                .background(.surface)
                .kiraScrollEdges()
        }
    }

    #Preview { DesignSystemGallery() }
#endif
