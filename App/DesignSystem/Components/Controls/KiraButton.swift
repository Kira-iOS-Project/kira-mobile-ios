// Button (design system): a capsule for one clear action, its label in Title Case on one line
// ("Lihat Rencana", "Nanti Saja"). At most one `primary` per screen. Two buttons side by side go
// through KiraButtonPair, which keeps the secondary on the left and the primary on the right.
import SwiftUI

/// Kira's capsule button.
struct KiraButton: View {
    /// What the button is for, and so how it looks.
    enum Variant: CaseIterable {
        /// Pandan fill: the action the screen is for.
        case primary
        /// The `button` fill with a `button-line` border: the equal choice, such as "Nanti Saja".
        case secondary
        /// Pandan text without a fill: an inline action.
        case quiet
        /// Red: only the 119 call and reporting ("Laporkan Grup", "Kirim Laporan").
        case darurat
        /// Terracotta: confirmations that delete ("Hapus Akun dan Data"); never red.
        case bahaya
    }

    /// The button's height.
    enum Size: CaseIterable {
        /// 50 pt (default).
        case medium
        /// 44 pt, the smallest touch target.
        case small
    }

    private let title: LocalizedStringResource
    private let variant: Variant
    private let size: Size
    private let action: () -> Void
    private var leadingIcon: KiraIconName?
    private var trailingIcon: KiraIconName?
    private var fillsWidth = false

    init(
        _ title: LocalizedStringResource, variant: Variant = .primary, size: Size = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: KiraSpacing.space2) {
                if let leadingIcon { KiraIcon(leadingIcon, size: 18, weight: .semibold) }
                Text(title).multilineTextAlignment(.center)
                if let trailingIcon { KiraIcon(trailingIcon, size: 18, weight: .semibold) }
            }
        }
        .buttonStyle(KiraButtonStyle(variant: variant, size: size, fillsWidth: fillsWidth))
    }

    /// The same button with an icon before its label.
    func icon(_ name: KiraIconName) -> Self {
        var button = self
        button.leadingIcon = name
        return button
    }

    /// The same button with an icon after its label.
    func iconEnd(_ name: KiraIconName) -> Self {
        var button = self
        button.trailingIcon = name
        return button
    }

    /// The same button, as wide as its container.
    func block() -> Self {
        var button = self
        button.fillsWidth = true
        return button
    }
}

/// A secondary and a primary button of equal width: the secondary on the left, the primary on the
/// right (Pilar Berdaya). At the accessibility text sizes they stack, the primary on top.
struct KiraButtonPair: View {
    private let secondary: KiraButton
    private let primary: KiraButton
    @Environment(\.dynamicTypeSize) private var typeSize

    init(secondary: KiraButton, primary: KiraButton) {
        self.secondary = secondary
        self.primary = primary
    }

    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(spacing: KiraSpacing.space2) {
                primary.block()
                secondary.block()
            }
        } else {
            HStack(spacing: KiraSpacing.space2) {
                secondary.block()
                primary.block()
            }
        }
    }
}

#if DEBUG
    #Preview { GalleryButtons().galleryPage() }
#endif
