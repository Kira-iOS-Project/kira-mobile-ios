/**
 Gallery page for consent and codes: the checkbox, the PIN and the email code (filling, and not
 accepted), and text links on their own and inside a sentence.
 */
#if DEBUG
    import SwiftUI

    struct GalleryEntry: View {
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var agreesToTerms = true
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var paydayAtMonthEnd = false
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var pin = "3814"
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var emailCode = "38"
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var wrongCode = "123456"

        var body: some View {
            GallerySection(title: "gallery.section.checkbox") {
                KiraCheckbox("gallery.checkbox.terms", isOn: $agreesToTerms)
                KiraCheckbox("gallery.checkbox.payday", isOn: $paydayAtMonthEnd)
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
    }

    #Preview { GalleryEntry().galleryPage() }
#endif
