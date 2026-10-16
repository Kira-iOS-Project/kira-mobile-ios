/**
 Gallery pages for navigation (nav bars, the dock, a sheet) and chat (bubbles and draft cards),
 each section the artifact's preview of the component with its words.
 */
#if DEBUG
    import SwiftUI

    struct GalleryNavigation: View {
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var tab = KiraTab.home
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var otherTab = KiraTab.home
        @State private var showsSheet = false

        var body: some View {
            GallerySection(title: "gallery.section.navbar") {
                VStack(spacing: 20) {
                    KiraNavBar(
                        "gallery.nav.detail", subtitle: "gallery.nav.detail.sub", leading: .back("gallery.back") {}
                    ) {
                        KiraHelpButton(.icon) {}
                    }
                    KiraNavBar("gallery.nav.modal", subtitle: "gallery.nav.modal.sub", leading: .close("ds.close") {})
                    KiraNavBar("gallery.nav.large", isLarge: true) { KiraHelpButton {} }
                        .eyebrow("gallery.nav.eyebrow")
                }
            }
            GallerySection(title: "gallery.section.tabbar") {
                KiraTabBar(selection: $tab) {}
                KiraTabBar(selection: $otherTab, isRecordActive: true) {}
            }
            GallerySection(title: "gallery.section.sheet") {
                KiraButton("gallery.sheet.open", variant: .secondary) { showsSheet = true }
                    .kiraSheet(
                        isPresented: $showsSheet, title: "gallery.sheet.title", subtitle: "gallery.sheet.subtitle"
                    ) {
                        GallerySheetContent { showsSheet = false }
                    }
            }
        }
    }

    /** The Sheet preview's content: category chips, a remembered choice, and the save button. */
    private struct GallerySheetContent: View {
        let onSave: () -> Void
        @State private var category = KiraCategory.transport
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var remembers = true

        var body: some View {
            KiraFlowRow {
                ForEach([KiraCategory.transport, .food, .bills], id: \.self) { option in
                    KiraChip(option.title, isSelected: option == category, leading: .category(option)) {
                        category = option
                    }
                }
            }
            KiraListGroup {
                KiraListRow(Text("gallery.sheet.remember"), leading: .icon(.sparkle), trailing: .toggle($remembers))
                    .subtitle(Text("gallery.sheet.remember.sub"))
            }
            Spacer(minLength: 0)
            KiraButton("gallery.sheet.save", action: onSave).block()
        }
    }

    struct GalleryChat: View {
        var body: some View {
            Text("gallery.chat.separator")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.inkMuted)
                .frame(maxWidth: .infinity)
            KiraChatBubble(.user, initial: "D") { Text("gallery.chat.me") }
            KiraChatBubble(.kira, meta: "gallery.chat.savedMeta") { Text("gallery.chat.saved") }
                .saved([
                    KiraSavedTransaction(
                        label: Text("gallery.chat.fuel"), amount: 30000, category: .transport,
                        categoryName: Text(KiraCategory.transport.title))
                ])
            KiraChatBubble(.kira, meta: "gallery.chat.meta") { Text("gallery.chat.kira") }
            KiraDraftCard(items: draft, total: 48000, onSave: {}, onEdit: { _ in })
            KiraDraftCard(items: Array(draft.prefix(1)), total: 25000, onSave: {}, onEdit: { _ in })
                .eyebrow("gallery.chat.receipt")
                .saveLabel("gallery.action.save")
                .secondary("gallery.action.continueChat") {}
            KiraChatBubble(.kira) { Text("gallery.chat.kira") }.hidesAvatar()
        }

        private var draft: [KiraDraftItem] {
            [
                KiraDraftItem(
                    label: Text("gallery.draft.lunch"), amount: 25000, category: .food,
                    categoryName: Text("gallery.draft.foodDrink")),
                KiraDraftItem(
                    label: Text("gallery.draft.ride"), amount: 18000, category: .transport,
                    categoryName: Text(KiraCategory.transport.title)),
                KiraDraftItem(
                    label: Text("gallery.draft.coffee"), amount: 5000, category: .coffee,
                    categoryName: Text("gallery.draft.foodDrink"), note: Text("gallery.draft.coffee.note")),
            ]
        }
    }

    #Preview { GalleryNavigation().galleryPage() }
    #Preview { GalleryChat().galleryPage() }
#endif
