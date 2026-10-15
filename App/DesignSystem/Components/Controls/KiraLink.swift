/**
 Text link (design system: `.k-link`): words that take the person somewhere, underlined so they
 read as a link without relying on colour.
   - KiraLink, a link on its own: pandan, semibold, 15 pt ("Kirim Ulang Kode", "Lupa PIN?"). The
     text keeps its size and the touch target grows to 44 pt around it.
   - KiraLinkText, links inside a sentence ("Dengan lanjut, kamu setuju dengan Syarat Layanan dan
     Kebijakan Privasi."): the String Catalog value marks each link in Markdown,
     `[Syarat Layanan](kira://syarat)`, drawn in ink, semibold and underlined in the muted sentence;
     a tap hands its URL to `onOpen`. VoiceOver lists the links in its Links rotor.
 SwiftUI draws the platform underline, not the canvas's 1.5 px line 3 px below the text. Something
 that changes data is a KiraButton, not a link. VoiceOver announces both as links.
 */
import SwiftUI

/** A text link on its own line. */
struct KiraLink: View {
    private let title: LocalizedStringResource
    private let action: () -> Void

    init(_ title: LocalizedStringResource, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .underline()
                .foregroundStyle(.pandan)
                .padding(.vertical, KiraSpacing.space1)
                .frame(minHeight: KiraSize.tap)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(.isLink)
    }
}

/** A sentence with links in it, written in Markdown in the String Catalog. */
struct KiraLinkText: View {
    private let text: LocalizedStringResource
    private let onOpen: (URL) -> Void

    init(_ text: LocalizedStringResource, onOpen: @escaping (URL) -> Void) {
        self.text = text
        self.onOpen = onOpen
    }

    var body: some View {
        Text(Self.styled(text))
            .font(.subheadline)
            .foregroundStyle(.inkMuted)
            .tint(.ink)
            .environment(
                \.openURL,
                OpenURLAction { url in
                    onOpen(url)
                    return .handled
                })
    }

    private static func styled(_ text: LocalizedStringResource) -> AttributedString {
        var styled = AttributedString(localized: text)
        var link = AttributeContainer()
        link.swiftUI.foregroundColor = .ink
        link.swiftUI.font = .subheadline.weight(.semibold)
        link.swiftUI.underlineStyle = .single
        for run in styled.runs where run.link != nil {
            styled[run.range].mergeAttributes(link)
        }
        return styled
    }
}

#if DEBUG
    #Preview { GalleryEntry().galleryPage() }
#endif
