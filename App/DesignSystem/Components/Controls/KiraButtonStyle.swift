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

    /**
     `.k-btn`'s `white-space: nowrap`: a label that does not fit its padding stays on one line and
     runs into it, down to 8 pt a side ("Pilih Gambar Lain" in half a pair); only a label that does
     not fit even then wraps (the accessibility sizes). `NoWrapPadding` picks the padding from the
     label's one-line width, so no text is ever cut to one line (`lineLimit`), which Apple's
     accessibility audit reports as clipped text and partial Dynamic Type support.
     */
    var body: some View {
        NoWrapPadding(full: horizontalPadding, least: KiraSpacing.space2) {
            label
                .font(size == .medium ? .headline : .subheadline.weight(.semibold))
                .kiraLineHeight(size == .medium ? 22 : 20, size: size == .medium ? 17 : 15)
                .foregroundStyle(foreground)
        }
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

/**
 Lays out one label with `full` padding a side when its one-line width fits the offer, else with
 `least` padding, where it runs into the padding and wraps only when even that is too narrow.
 */
private struct NoWrapPadding: Layout {
    let full: CGFloat
    let least: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        guard let label = subviews.first else { return .zero }
        let padding = padding(for: label, in: proposal.width)
        let inner = label.sizeThatFits(
            ProposedViewSize(width: proposal.width.map { max($0 - 2 * padding, 0) }, height: nil))
        return CGSize(width: inner.width + 2 * padding, height: inner.height)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        guard let label = subviews.first else { return }
        let padding = padding(for: label, in: bounds.width)
        let width = max(bounds.width - 2 * padding, 0)
        label.place(
            at: CGPoint(x: bounds.midX, y: bounds.midY), anchor: .center,
            proposal: ProposedViewSize(width: width, height: bounds.height))
    }

    private func padding(for label: LayoutSubview, in width: CGFloat?) -> CGFloat {
        guard let width else { return full }
        return label.sizeThatFits(.unspecified).width + 2 * full <= width ? full : least
    }
}
