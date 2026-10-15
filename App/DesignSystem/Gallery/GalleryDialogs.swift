// Gallery page for dialogs: success, failure, a confirmation that deletes and one that does not, the
// round-icon art, each shown inline on the scrim, and one presented over the whole window.
#if DEBUG
    import SwiftUI

    struct GalleryDialogs: View {
        @State private var isConfirming = false

        var body: some View {
            GallerySection(title: "gallery.section.dialogPresented") {
                KiraButton("gallery.dialog.open", variant: .secondary) { isConfirming = true }
                    .kiraDialog(isPresented: $isConfirming) {
                        KiraDialog(
                            "gallery.dialog.unsubscribe.title", message: "gallery.dialog.unsubscribe.body",
                            art: .illustration(.peduli),
                            primary: KiraButton("gallery.dialog.unsubscribe", variant: .bahaya) {},
                            secondary: KiraButton("gallery.dialog.keep", variant: .secondary) {})
                    }
            }
            GallerySection(title: "gallery.section.dialogSuccess") {
                KiraDialog(
                    "gallery.dialog.saved.title", message: "gallery.dialog.saved.body", art: .illustration(.mekar),
                    primary: KiraButton("gallery.dialog.done") {}
                )
                .onScrim()
            }
            GallerySection(title: "gallery.section.dialogFailure") {
                KiraDialog(
                    "gallery.dialog.failed.title", message: "gallery.dialog.failed.body", art: .illustration(.payung),
                    primary: KiraButton("gallery.dialog.retry") {},
                    secondary: KiraButton("gallery.dialog.close", variant: .secondary) {}
                )
                .onScrim()
            }
            GallerySection(title: "gallery.section.dialogConfirm") {
                KiraDialog(
                    "gallery.dialog.delete.title", message: "gallery.dialog.delete.body", art: .illustration(.peduli),
                    primary: KiraButton("gallery.dialog.delete", variant: .bahaya) {},
                    secondary: KiraButton("gallery.dialog.cancel", variant: .secondary) {}
                )
                .onScrim()
                KiraDialog(
                    "gallery.dialog.download.title", message: "gallery.dialog.download.body",
                    art: .illustration(.perisai), primary: KiraButton("gallery.dialog.download") {},
                    secondary: KiraButton("gallery.dialog.cancel", variant: .secondary) {}
                )
                .onScrim()
            }
            GallerySection(title: "gallery.section.dialogIcon") {
                KiraDialog(
                    "gallery.dialog.linked.title", message: "gallery.dialog.linked.body", art: .success,
                    primary: KiraButton("gallery.dialog.done") {}
                )
                .onScrim()
                KiraDialog(
                    "gallery.dialog.offline.title", message: "gallery.dialog.offline.body", art: .failure,
                    primary: KiraButton("gallery.dialog.retry") {},
                    secondary: KiraButton("gallery.dialog.close", variant: .secondary) {}
                )
                .onScrim()
            }
        }
    }

    extension View {
        /// The dialog as it sits over a screen: on the scrim, 24 pt from the edges.
        fileprivate func onScrim() -> some View {
            padding(.horizontal, KiraSpacing.space6)
                .padding(.vertical, KiraSpacing.space8)
                .background(.scrim, in: RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous))
        }
    }

    #Preview { GalleryDialogs().galleryPage() }
#endif
