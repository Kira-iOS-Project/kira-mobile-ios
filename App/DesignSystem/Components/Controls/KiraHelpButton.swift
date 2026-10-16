/**
 HelpButton (design system): the way into Kira Peduli, "Butuh Bantuan Sekarang", on every main
 screen. Calm, never red: a pandan duotone heart in a pandan-soft circle on a `button` capsule. A tap opens
 the help sheet over the current screen without closing the chat or a form.
 */
import SwiftUI

/** The Kira Peduli button. */
struct KiraHelpButton: View {
    /** Where the button sits. */
    enum Variant: CaseIterable {
        /** A pill in the top bar, beside the greeting or the title (default). */
        case pill
        /** 44 pt, heart only, when the bar is full. */
        case icon
        /** Full width, in Profil and inside sheets. */
        case row
    }

    private let variant: Variant
    private let action: () -> Void
    private let label: LocalizedStringResource

    /** `label` replaces "Butuh Bantuan Sekarang", as on a row that names the counsellor. */
    init(_ variant: Variant = .pill, label: LocalizedStringResource = "ds.help.label", action: @escaping () -> Void) {
        self.variant = variant
        self.label = label
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                heart
                if variant != .icon {
                    Text(label)
                    if variant == .row { Spacer(minLength: 0) }
                }
            }
            .font(variant == .row ? .subheadline.weight(.semibold) : .footnote.weight(.semibold))
            .kiraLineHeight(18, size: variant == .row ? 15 : 13)
            .foregroundStyle(.ink)
            .padding(insets)
            .frame(minWidth: variant == .icon ? KiraSize.tap : nil, minHeight: minHeight)
            .frame(maxWidth: variant == .row ? .infinity : nil)
            .kiraCard(.button, border: .buttonLine, cornerRadius: variant == .row ? KiraRadius.medium : KiraRadius.full)
            /** The pill is 34 pt high; the padding brings its touch target to 44 pt. */
            .padding(.vertical, variant == .pill ? 5 : 0)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }

    private var insets: EdgeInsets {
        switch variant {
        case .pill: EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: KiraSpacing.space3)
        case .icon: EdgeInsets()
        case .row: EdgeInsets(top: 0, leading: KiraSpacing.space3, bottom: 0, trailing: KiraSpacing.space4)
        }
    }

    private var minHeight: CGFloat {
        switch variant {
        case .pill: 34
        case .icon: KiraSize.tap
        case .row: 52
        }
    }

    private var heart: some View {
        let side: CGFloat = variant == .icon ? 32 : 24
        /** The design system's duotone heart, 20 pt in the icon button and 15 pt in the pill and row. */
        return KiraIcon(.heart, size: variant == .icon ? 20 : 15, weight: .semibold, isFilled: true)
            .foregroundStyle(.pandan)
            .frame(width: side, height: side)
            .background(.pandanSoft, in: Circle())
            .accessibilityHidden(true)
    }
}

#if DEBUG
    #Preview { GalleryButtons().galleryPage() }
#endif
