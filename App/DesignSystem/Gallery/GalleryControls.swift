// Gallery pages for the controls: buttons, the secondary and primary pair, icon buttons, the help
// button, fields, the switch, the segmented control and chips.
#if DEBUG
    import SwiftUI

    struct GalleryButtons: View {
        var body: some View {
            GallerySection(title: "gallery.section.button") {
                KiraButton("gallery.action.seePlan") {}
                KiraButton("ds.later", variant: .secondary) {}
                KiraButton("gallery.action.howCalculated", variant: .quiet) {}
                KiraButton("gallery.action.call119", variant: .darurat) {}.icon(.phone)
                KiraButton("gallery.action.deleteAccount", variant: .bahaya) {}.icon(.trash)
                KiraButton("gallery.action.continueChat", variant: .secondary, size: .small) {}
                KiraButton("gallery.action.start") {}.iconEnd(.arrowRight).block()
            }
            GallerySection(title: "gallery.section.pair") {
                KiraButtonPair(
                    secondary: KiraButton("ds.later", variant: .secondary) {},
                    primary: KiraButton("gallery.action.seePlan") {})
            }
            GallerySection(title: "gallery.section.iconButton") {
                HStack(spacing: KiraSpacing.space3) {
                    KiraIconButton.back("gallery.back.home") {}
                    KiraIconButton.close {}
                    KiraIconButton(.eye, label: "gallery.action.hideBalance") {}
                    KiraIconButton(.share, label: "gallery.action.share", variant: .outline) {}
                }
            }
            GallerySection(title: "gallery.section.help") {
                HStack(spacing: KiraSpacing.space3) {
                    KiraHelpButton {}
                    KiraHelpButton(.icon) {}
                }
                KiraHelpButton(.row) {}
            }
        }
    }

    struct GalleryForms: View {
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var amount = ""
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var note = ""
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var nickname = ""
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var hidesBalance = true
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var method = "snowball"
        @State private var debts: Set<String> = ["paylater"]

        var body: some View {
            GallerySection(title: "gallery.section.field") {
                KiraField("gallery.field.amount", text: $amount, prompt: "gallery.field.amount.prompt")
                    .prefix("gallery.field.rupiah")
                    .hint("gallery.field.amount.hint")
                    .keyboardType(.numberPad)
                KiraField("gallery.field.note", text: $note, prompt: "gallery.field.note.prompt").multiline(3)
                KiraField("gallery.field.nickname", text: $nickname).error("gallery.field.nickname.error")
                KiraField("gallery.field.share", text: $note).suffix("gallery.field.percent")
            }
            GallerySection(title: "gallery.section.toggle") {
                KiraToggle("gallery.toggle.hideBalance", isOn: $hidesBalance)
            }
            GallerySection(title: "gallery.section.segmented") {
                KiraSegmented(
                    "gallery.segmented.label",
                    options: [
                        .init(id: "snowball", title: "gallery.segmented.snowball"),
                        .init(id: "avalanche", title: "gallery.segmented.avalanche"),
                    ], selection: $method)
            }
            GallerySection(title: "gallery.section.chip") { chips }
        }

        private var chips: some View {
            KiraFlowRow {
                KiraChip("ds.category.paylater", isSelected: debts.contains("paylater")) { toggle("paylater") }
                KiraChip("ds.category.pinjol", isSelected: debts.contains("pinjol")) { toggle("pinjol") }
                KiraChip("ds.category.kartu", isSelected: debts.contains("kartu"), leading: .icon(.card)) {
                    toggle("kartu")
                }
                KiraChip("ds.category.makan", isSelected: debts.contains("makan"), leading: .category(.makan)) {
                    toggle("makan")
                }
            }
        }

        private func toggle(_ id: String) {
            if debts.contains(id) { debts.remove(id) } else { debts.insert(id) }
        }
    }

    #Preview { GalleryForms().galleryPage() }
#endif
