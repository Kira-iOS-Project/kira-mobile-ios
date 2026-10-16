/**
 Gallery pages for the controls, each section the artifact's preview of the component with its
 words: buttons, icon buttons and the help button; fields, switches, segmented controls and chips.
 A few more variants follow a preview where the component has them.
 */
#if DEBUG
    import SwiftUI

    struct GalleryButtons: View {
        var body: some View {
            GallerySection(title: "gallery.section.button") {
                KiraButtonPair(
                    secondary: KiraButton("ds.later", variant: .secondary) {},
                    primary: KiraButton("gallery.action.seePlan") {})
                KiraFlowRow {
                    KiraButton("gallery.action.scanReceipt", variant: .secondary, size: .small) {}.icon(.camera)
                    KiraButton("gallery.action.changeCategory", variant: .quiet, size: .small) {}
                    KiraButton("gallery.action.call119", variant: .emergency, size: .small) {}.icon(.phone)
                    KiraButton("gallery.action.deletePermanently", variant: .destructive, size: .small) {}.icon(.trash)
                }
                KiraButton("gallery.action.start") {}.iconEnd(.arrowRight).block()
            }
            GallerySection(title: "gallery.section.iconButton") {
                HStack(spacing: KiraSpacing.space4) {
                    KiraIconButton.back("gallery.back.home") {}
                    KiraIconButton(.eye, label: "gallery.action.hideBalance") {}
                    KiraIconButton(.info, label: "gallery.action.aboutNumber", variant: .outline) {}
                    KiraIconButton.close {}
                }
            }
            GallerySection(title: "gallery.section.help") {
                HStack(spacing: KiraSpacing.space3) {
                    KiraHelpButton {}
                    KiraHelpButton(.icon) {}
                }
                KiraHelpButton(.row, label: "gallery.help.counsellor") {}
            }
        }
    }

    struct GalleryForms: View {
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var income = "7.500.000"
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var entity = ""
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var email = "dinda@"
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var note = ""
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var remindsOn = true
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var remindsOff = false
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var kind = "spending"
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var method = "avalanche"

        var body: some View {
            GallerySection(title: "gallery.section.field") {
                KiraField("gallery.field.income", text: $income)
                    .prefix("gallery.field.rupiah")
                    .hint("gallery.field.income.hint")
                    .keyboardType(.numberPad)
                KiraField("gallery.field.entity", text: $entity, prompt: "gallery.field.entity.prompt").icon(.search)
                KiraField("gallery.field.email", text: $email).error("gallery.field.email.error")
                KiraField("gallery.field.note", text: $note, prompt: "gallery.field.note.prompt").multiline(3)
                KiraField("gallery.field.share", text: $note).suffix("gallery.field.percent")
            }
            GallerySection(title: "gallery.section.toggle") {
                HStack(spacing: KiraSpacing.space3) {
                    KiraToggle("gallery.toggle.remindersOn", isOn: $remindsOn)
                    KiraToggle("gallery.toggle.remindersOff", isOn: $remindsOff)
                }
            }
            GallerySection(title: "gallery.section.segmented") {
                KiraSegmented(
                    "gallery.segmented.kind",
                    options: [
                        .init(id: "spending", title: "gallery.segmented.spending"),
                        .init(id: "income", title: "gallery.segmented.income"),
                    ], selection: $kind)
                KiraSegmented(
                    "gallery.segmented.label",
                    options: [
                        .init(id: "snowball", title: "gallery.segmented.snowball"),
                        .init(id: "avalanche", title: "gallery.segmented.avalanche"),
                    ], selection: $method)
            }
            GallerySection(title: "gallery.section.chip") { GalleryChips() }
        }
    }

    /** The Chip preview: two plain chips, two with a category tile and one with an icon. */
    private struct GalleryChips: View {
        @State private var chosen: Set<String> = ["bpjs", "paylater"]

        var body: some View {
            KiraFlowRow {
                chip("bpjs", "gallery.chip.bpjs")
                chip("life", "gallery.chip.lifeInsurance")
                chip("paylater", "ds.category.paylater", leading: .category(.paylater))
                chip("online-loan", "ds.category.onlineLoan", leading: .category(.onlineLoan))
                chip("all", "gallery.chip.allCategories", leading: .icon(.filter))
            }
        }

        private func chip(
            _ id: String, _ title: LocalizedStringResource, leading: KiraChip.Leading = .none
        ) -> KiraChip {
            KiraChip(title, isSelected: chosen.contains(id), leading: leading) {
                if chosen.contains(id) { chosen.remove(id) } else { chosen.insert(id) }
            }
        }
    }

    #Preview { GalleryForms().galleryPage() }
#endif
