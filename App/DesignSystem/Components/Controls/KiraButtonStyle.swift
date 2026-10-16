/**
 The look of KiraButton (bundle.css .k-btn): a capsule at least 50 pt (md) or 44 pt (sm) high,
 growing with Dynamic Type, with no shadow; a pressed button darkens its fill instead.
 */
import SwiftUI

/** The capsule look of a KiraButton. */
struct KiraButtonStyle: ButtonStyle {
    let variant: KiraButton.Variant
    let size: KiraButton.Size
    let fillsWidth: Bool

    func makeBody(configuration: Configuration) -> some View {
        KiraButtonBody(
            label: configuration.label, isPressed: configuration.isPressed, variant: variant, size: size,
            fillsWidth: fillsWidth)
    }
}

private struct KiraButtonBody<Label: View>: View {
    let label: Label
    let isPressed: Bool
    let variant: KiraButton.Variant
    let size: KiraButton.Size
    let fillsWidth: Bool

    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric(relativeTo: .headline) private var mediumHeight: CGFloat = 50
    @ScaledMetric(relativeTo: .subheadline) private var smallHeight: CGFloat = 44

    var body: some View {
        label
            .font(size == .medium ? .headline : .subheadline.weight(.semibold))
            .kiraLineHeight(size == .medium ? 22 : 20, size: size == .medium ? 17 : 15)
            .foregroundStyle(foreground)
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: size == .medium ? mediumHeight : smallHeight)
            .background(fill, in: Capsule())
            .capsuleHairline(border)
            .contentShape(Capsule())
            .opacity(isEnabled ? 1 : 0.45)
    }

    private var horizontalPadding: CGFloat {
        if variant == .quiet { return KiraSpacing.space3 }
        return size == .medium ? KiraSpacing.space5 : KiraSpacing.space4
    }

    private var foreground: Color {
        switch variant {
        case .primary: .onPandan
        case .secondary: .ink
        case .quiet: .pandan
        case .emergency: .onEmergency
        case .destructive: .vulnerable
        }
    }

    private var fill: Color {
        switch variant {
        case .primary: isPressed ? .pandanStrong : .pandan
        case .secondary: isPressed ? .surfaceMuted : .button
        case .quiet: isPressed ? .pandanSoft : .clear
        case .emergency: .emergency
        case .destructive: isPressed ? .surfaceMuted : .vulnerableSoft
        }
    }

    private var border: Color {
        switch variant {
        case .secondary: .buttonLine
        case .destructive: .vulnerableLine
        case .primary, .quiet, .emergency: .clear
        }
    }
}
