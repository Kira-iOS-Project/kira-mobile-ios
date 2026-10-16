/**
 Gallery page for lists, each section the artifact's preview of the component with its words:
 section titles, a list group of wallets, and a list of settings rows; then the row parts the
 previews leave out.
 */
#if DEBUG
    import SwiftUI

    struct GalleryLists: View {
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var locks = true
        @State private var isSnowball = true

        var body: some View {
            GallerySection(title: "gallery.section.sectionTitle") {
                KiraSectionTitle("gallery.list.nextStep", trailing: .note("gallery.hand.start"))
                KiraSectionTitle("gallery.list.bills", trailing: .action("gallery.list.seeAll", {}))
                KiraSectionTitle("gallery.list.history", showsLeaf: false)
            }
            GallerySection(title: "gallery.section.listGroup") {
                KiraListGroup("gallery.list.wallets", footer: "gallery.list.wallets.footer") {
                    KiraListRow(Text("gallery.list.salary"), leading: .category(.bank), action: {})
                        .subtitle(Text("ds.category.bank"))
                        .amount(KiraAmount(4_250_000, size: .small))
                    KiraListRow(Text("gallery.list.ewallet"), leading: .category(.ewallet), action: {})
                        .subtitle(Text("gallery.list.ewallet.sub"))
                        .amount(KiraAmount(312_000, size: .small))
                    KiraListRow(
                        Text("gallery.list.paylater"), leading: .category(.paylater), action: {},
                        extra: { KiraTag("gallery.tag.soon", tone: .turmeric, icon: .clock) }
                    )
                    .subtitle(Text("gallery.list.paylater.sub"))
                    .amount(KiraAmount(420_000, size: .small))
                }
            }
            GallerySection(title: "gallery.section.listRow") {
                KiraListGroup("gallery.list.settings") {
                    KiraListRow(Text("gallery.list.pin"), leading: .icon(.lock), trailing: .toggle($locks))
                        .subtitle(Text("gallery.list.pin.sub"))
                    KiraListRow(Text("gallery.action.hideBalance"), leading: .icon(.eyeOff), action: {})
                        .value(Text("gallery.list.hide.value"))
                    KiraListRow(Text("gallery.list.coffee"), leading: .category(.coffee), action: {})
                        .subtitle(Text("gallery.list.coffee.sub"))
                        .amount(KiraAmount(5000, size: .small))
                    KiraListRow(
                        Text("gallery.segmented.snowball"), trailing: .check(isSnowball),
                        action: { isSnowball.toggle() }
                    )
                    .subtitle(Text("gallery.list.snowball.sub"))
                    KiraListRow(Text("gallery.action.deleteAccount"), leading: .icon(.trash), action: {}).danger()
                }
                KiraListGroup {
                    KiraListRow(Text("gallery.list.weekly"), leading: .illustration(.letter), action: {})
                        .value(Text("gallery.list.weekly.value"))
                    KiraListRow(Text("gallery.list.ojk"), leading: .icon(.shield), trailing: .external, action: {})
                    KiraListRow(Text("gallery.list.admin"), leading: .initials("D", .green))
                        .subtitle(Text("gallery.list.admin.sub"))
                    KiraListRow(
                        Text("gallery.list.goal"), leading: .category(.savings),
                        extra: { KiraProgressRibbon(value: 2, target: 6) }
                    )
                    .amount(KiraAmount(2_450_000, size: .medium).masked())
                }
            }
        }
    }

    #Preview { GalleryLists().galleryPage() }
#endif
