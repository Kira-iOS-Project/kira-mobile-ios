/**
 Gallery page for consent and codes: the checkbox, Pilih Tanggal Gajian (the payday sheet onboarding
 and Atur Budget share), the PIN and the email code (filling, and not accepted), and text links on
 their own and inside a sentence.
 */
#if DEBUG
    import Domain
    import SwiftUI

    struct GalleryEntry: View {
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var agreesToTerms = true
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var paydayAtMonthEnd = false
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var isPaydayPickerPresented = false
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var payday = Payday(day: Payday.defaultDay)
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var pin = "3814"
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var emailCode = "38"
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var wrongCode = "123456"

        var body: some View {
            VStack(alignment: .leading, spacing: KiraSpacing.space6) {
                GallerySection(title: "gallery.section.checkbox") {
                    KiraCheckbox("gallery.checkbox.terms", isOn: $agreesToTerms)
                    KiraCheckbox("gallery.checkbox.payday", isOn: $paydayAtMonthEnd)
                }
                GallerySection(title: "gallery.section.payday") {
                    paydaySelectionLabel.font(.subheadline).foregroundStyle(.inkMuted)
                    KiraButton("gallery.payday.open", variant: .secondary) {
                        isPaydayPickerPresented = true
                    }
                    .block()
                }
                GallerySection(title: "gallery.section.pin") {
                    KiraCodeField("gallery.code.pin", code: $pin, kind: .pin).hint("gallery.code.pin.hint")
                }
                GallerySection(title: "gallery.section.code") {
                    KiraCodeField("gallery.code.email", code: $emailCode, kind: .code)
                    KiraCodeField("gallery.code.email", code: $wrongCode, kind: .code).error("gallery.code.email.error")
                }
                GallerySection(title: "gallery.section.link") {
                    KiraLink("gallery.link.resend") {}
                    KiraLinkText("gallery.link.terms") { _ in }
                }
            }
            .kiraPaydayPicker(isPresented: $isPaydayPickerPresented, payday: $payday)
        }

        private var paydaySelectionLabel: Text {
            guard let day = payday.day else { return Text("gallery.payday.endOfMonth") }
            return Text("gallery.payday.day \(day)")
        }
    }

    #Preview { GalleryEntry().galleryPage() }
#endif
