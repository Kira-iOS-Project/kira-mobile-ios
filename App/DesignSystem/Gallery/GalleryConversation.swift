// Gallery pages for navigation (nav bars, the dock, a sheet) and chat (bubbles and a draft card).
#if DEBUG
    import SwiftUI

    struct GalleryNavigation: View {
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var tab = KiraTab.beranda
        @State private var isCatat = false
        @State private var showsSheet = false
        @State private var category = KiraCategory.makan

        var body: some View {
            GallerySection(title: "gallery.section.navbar") {
                KiraNavBar("gallery.nav.large", isLarge: true) { KiraHelpButton {} }
                    .eyebrow("gallery.nav.eyebrow")
                KiraNavBar(
                    "gallery.nav.detail", subtitle: "gallery.nav.detail.sub", leading: .back("gallery.back.home") {}
                ) {
                    KiraHelpButton(.icon) {}
                }
                KiraNavBar("gallery.nav.modal", leading: .close("ds.close") {})
            }
            GallerySection(title: "gallery.section.tabbar") {
                KiraTabBar(selection: $tab, isCatatActive: isCatat) { isCatat.toggle() }
            }
            GallerySection(title: "gallery.section.sheet") {
                KiraButton("gallery.sheet.open", variant: .secondary) { showsSheet = true }
            }
            .kiraSheet(isPresented: $showsSheet, title: "gallery.sheet.title", subtitle: "gallery.sheet.subtitle") {
                KiraFlowRow {
                    ForEach([KiraCategory.makan, .kopi, .belanja, .transportasi], id: \.self) { option in
                        KiraChip(option.title, isSelected: option == category, leading: .category(option)) {
                            category = option
                        }
                    }
                }
                Spacer()
                KiraButton("gallery.action.save") { showsSheet = false }.block()
            }
        }
    }

    struct GalleryChat: View {
        var body: some View {
            Text("gallery.chat.separator")
                .font(.caption.weight(.medium))
                .foregroundStyle(.inkMuted)
                .frame(maxWidth: .infinity)
            KiraChatBubble(.user, initial: "D") { Text("gallery.chat.me") }
            KiraChatBubble(.kira, meta: "gallery.chat.meta") { Text("gallery.chat.kira") }
            KiraDraftCard(items: draft, total: 48000, onSave: {}, onEdit: { _ in })
                .secondary("gallery.action.continueChat") {}
            KiraDraftCard(items: Array(draft.prefix(1)), total: 25000, onSave: {}, onEdit: { _ in })
                .eyebrow("gallery.chat.receipt")
                .saveLabel("gallery.action.save")
            KiraChatBubble(.kira, meta: "gallery.chat.savedMeta") { Text("gallery.chat.saved") }
                .saved([
                    KiraSavedTransaction(
                        label: Text("gallery.draft.lunch"), amount: 25000, category: .makan,
                        categoryName: Text(KiraCategory.makan.title))
                ])
            KiraChatBubble(.kira) { Text("gallery.chat.kira") }.hidesAvatar()
        }

        private var draft: [KiraDraftItem] {
            [
                KiraDraftItem(
                    label: Text("gallery.draft.lunch"), amount: 25000, category: .makan,
                    categoryName: Text(KiraCategory.makan.title)),
                KiraDraftItem(
                    label: Text("gallery.draft.ride"), amount: 18000, category: .transportasi,
                    categoryName: Text(KiraCategory.transportasi.title)),
                KiraDraftItem(
                    label: Text("gallery.draft.coffee"), amount: 5000, category: .kopi,
                    categoryName: Text(KiraCategory.kopi.title), note: Text("gallery.draft.coffee.note")),
            ]
        }
    }

    #Preview { GalleryNavigation().galleryPage() }
    #Preview { GalleryChat().galleryPage() }
#endif
