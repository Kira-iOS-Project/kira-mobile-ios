/**
 The tappable card of Beranda (Kira Score, Ringkasan Mingguan): a 56 pt illustration tile, two
 lines of text, and a chevron, as one button named by its whole sentence.
 */
import SwiftUI

struct KiraTapCard<Content: View>: View {
    private let illustration: KiraIllustrationName
    private let label: Text
    private let action: () -> Void
    private let content: Content

    init(
        _ illustration: KiraIllustrationName, label: Text, action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.illustration = illustration
        self.label = label
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: KiraSpacing.space3) {
                KiraIllustration(illustration, size: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .hairline(cornerRadius: 16)
                VStack(alignment: .leading, spacing: 2) { content }
                    .frame(maxWidth: .infinity, alignment: .leading)
                KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted)
            }
            .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 14))
            .kiraCard()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}
