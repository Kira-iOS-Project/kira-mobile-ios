/**
 IconButton (design system): a 44 pt round button holding only an icon, always with a name for
 VoiceOver. A back button is always `.back`: the outline variant with chevron-left, never the
 previous screen's title, named after where it goes ("Kembali ke Beranda").
 */
import SwiftUI

/** A round, icon-only button with a required accessible name. */
struct KiraIconButton: View {
    /** The button's surface. */
    enum Variant: CaseIterable {
        /** No fill: actions inside cards, such as the eye that hides a balance (default). */
        case plain
        /** The `button` fill with a `button-line` border: navigation in the top bar. */
        case outline
    }

    private let icon: KiraIconName
    private let label: LocalizedStringResource
    private let variant: Variant
    private let action: () -> Void

    init(
        _ icon: KiraIconName, label: LocalizedStringResource, variant: Variant = .plain,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.label = label
        self.variant = variant
        self.action = action
    }

    /** The back button: outline, chevron-left, named after its destination. */
    static func back(_ label: LocalizedStringResource, action: @escaping () -> Void) -> Self {
        Self(.chevronLeft, label: label, variant: .outline, action: action)
    }

    /** The close button of a modal screen or a sheet: outline, an X, on the right of a sheet. */
    static func close(_ label: LocalizedStringResource = "ds.close", action: @escaping () -> Void) -> Self {
        Self(.close, label: label, variant: .outline, action: action)
    }

    var body: some View {
        Button(action: action) {
            KiraIcon(icon, size: 22, weight: .semibold)
        }
        .buttonStyle(KiraIconButtonStyle(variant: variant))
        .accessibilityLabel(Text(label))
    }
}

private struct KiraIconButtonStyle: ButtonStyle {
    let variant: KiraIconButton.Variant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(variant == .outline || configuration.isPressed ? Color.ink : Color.inkMuted)
            .frame(width: KiraSize.tap, height: KiraSize.tap)
            .background(fill(pressed: configuration.isPressed), in: Circle())
            .overlay { Circle().strokeBorder(variant == .outline ? Color.buttonLine : .clear, lineWidth: 1) }
            .contentShape(Circle())
    }

    private func fill(pressed: Bool) -> Color {
        if pressed { return .surfaceMuted }
        return variant == .outline ? .button : .clear
    }
}

#if DEBUG
    #Preview { GalleryButtons().galleryPage() }
#endif
