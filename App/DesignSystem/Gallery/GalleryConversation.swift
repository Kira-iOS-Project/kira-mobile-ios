/** Gallery pages for navigation (nav bars, the dock, a sheet) and chat (bubbles and a draft card). */
#if DEBUG
    import SwiftUI

    struct GalleryNavigation: View {
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var tab = KiraTab.home
        @State private var isRecording = false
        @State private var showsSheet = false
        @State private var category = KiraCategory.food

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
                KiraTabBar(selection: $tab, isRecordActive: isRecording) { isRecording.toggle() }
            }
            GallerySection(title: "gallery.section.sheet") {
                KiraButton("gallery.sheet.open", variant: .secondary) { showsSheet = true }
            }
            .kiraSheet(isPresented: $showsSheet, title: "gallery.sheet.title", subtitle: "gallery.sheet.subtitle") {
                KiraFlowRow {
                    ForEach([KiraCategory.food, .coffee, .shopping, .transport], id: \.self) { option in
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
                        label: Text("gallery.draft.lunch"), amount: 25000, category: .food,
                        categoryName: Text(KiraCategory.food.title))
                ])
            KiraChatBubble(.kira) { Text("gallery.chat.kira") }.hidesAvatar()
        }

        private var draft: [KiraDraftItem] {
            [
                KiraDraftItem(
                    label: Text("gallery.draft.lunch"), amount: 25000, category: .food,
                    categoryName: Text(KiraCategory.food.title)),
                KiraDraftItem(
                    label: Text("gallery.draft.ride"), amount: 18000, category: .transport,
                    categoryName: Text(KiraCategory.transport.title)),
                KiraDraftItem(
                    label: Text("gallery.draft.coffee"), amount: 5000, category: .coffee,
                    categoryName: Text(KiraCategory.coffee.title), note: Text("gallery.draft.coffee.note")),
            ]
        }
    }

    #Preview { GalleryNavigation().galleryPage() }
    #Preview { GalleryChat().galleryPage() }
#endif
