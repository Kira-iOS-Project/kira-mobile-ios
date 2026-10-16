/**
 NavBar (design system): every screen opens with it. Inner screens: an icon-only back button
 (never the previous title), the title centred in Title Case on one line, at most two actions on
 the right (KiraHelpButton on every main screen). Modals: `.close`. Tab roots (Beranda, Rencana,
 Komunitas): `isLarge`, a large left-aligned title with a small eyebrow above it (a date or the pay
 period). Hide the system bar on screens that use it: `.toolbar(.hidden, for: .navigationBar)`.
 */
import SwiftUI

/** The top bar of a screen. */
struct KiraNavBar<Trailing: View>: View {
    /** The button on the left. */
    enum Leading {
        /** Nothing (default). */
        case none
        /** The back button, named after where it goes ("Kembali ke Beranda"). */
        case back(LocalizedStringResource, () -> Void)
        /** The close button of a modal screen ("Tutup"). */
        case close(LocalizedStringResource, () -> Void)
    }

    private let title: LocalizedStringResource
    private let subtitle: LocalizedStringResource?
    private let leading: Leading
    private let isLarge: Bool
    private let trailing: Trailing
    private var eyebrow: LocalizedStringResource?
    @Environment(\.dynamicTypeSize) private var typeSize

    init(
        _ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, leading: Leading = .none,
        isLarge: Bool = false, @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading
        self.isLarge = isLarge
        self.trailing = trailing()
    }

    var body: some View {
        if isLarge { large } else { inline }
    }

    @ViewBuilder private var inline: some View {
        /** At the accessibility text sizes the title moves under the buttons, so they never squeeze it. */
        if typeSize.isAccessibilitySize {
            VStack(spacing: KiraSpacing.space2) {
                HStack(spacing: KiraSpacing.space2) {
                    leadingButton
                    Spacer(minLength: 0)
                    HStack(spacing: KiraSpacing.space1) { trailing }
                }
                titles
            }
        } else {
            inlineRow
        }
    }

    private var titles: some View {
        VStack(spacing: 0) {
            Text(title).font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(subtitle).font(.caption).kiraLineHeight(16, size: 12).foregroundStyle(.inkMuted)
            }
        }
        .multilineTextAlignment(.center)
    }

    private var inlineRow: some View {
        HStack(spacing: KiraSpacing.space2) {
            leadingButton.frame(maxWidth: .infinity, alignment: .leading)
            titles
                .frame(maxWidth: 230)
                .layoutPriority(1)
            HStack(spacing: KiraSpacing.space1) { trailing }.fixedSize().frame(
                maxWidth: .infinity, alignment: .trailing)
        }
        .frame(minHeight: KiraSize.tap)
    }

    /**
     `.k-nav--large`: the button row, then the eyebrow 2 pt above the title (a 16 pt row gap less its
     -14 pt margin), and the trailing buttons centred on the title and its subtitle.
     */
    private var large: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            leadingButton
            VStack(alignment: .leading, spacing: 2) {
                if let eyebrow {
                    Text(eyebrow).font(.footnote.weight(.medium)).kiraLineHeight(18, size: 13)
                        .foregroundStyle(.inkMuted)
                }
                largeTitleRow
            }
            if typeSize.isAccessibilitySize {
                HStack(spacing: KiraSpacing.space1) { trailing }
            }
        }
    }

    private var largeTitleRow: some View {
        HStack(alignment: .center, spacing: KiraSpacing.space2) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(KiraFont.display(28, .heavy, relativeTo: .title)).kiraLineHeight(
                        34, size: 28, natural: 1.26, relativeTo: .title
                    )
                    .tracking(-0.56)
                    /** `.k-nav__large` neither truncates nor shrinks: a long title wraps. */
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                if let subtitle {
                    Text(subtitle).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if !typeSize.isAccessibilitySize {
                HStack(spacing: KiraSpacing.space1) { trailing }.fixedSize()
            }
        }
    }

    @ViewBuilder private var leadingButton: some View {
        switch leading {
        case .none: EmptyView()
        case .back(let label, let action): KiraIconButton.back(label, action: action)
        case .close(let label, let action): KiraIconButton.close(label, action: action)
        }
    }

    /** The same large bar with a small line above the title ("Kamis, 15 Oktober 2026"). */
    func eyebrow(_ text: LocalizedStringResource) -> Self {
        var bar = self
        bar.eyebrow = text
        return bar
    }
}

extension KiraNavBar where Trailing == EmptyView {
    init(
        _ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, leading: Leading = .none,
        isLarge: Bool = false
    ) {
        self.init(title, subtitle: subtitle, leading: leading, isLarge: isLarge) { EmptyView() }
    }
}

#if DEBUG
    #Preview { GalleryNavigation().galleryPage() }
#endif
