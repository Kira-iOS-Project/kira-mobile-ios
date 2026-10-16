/**
 The frame the Paket, Langganan, Traktir Kira and Beasiswa Kira boards share: a scrolling 16 pt
 column with 16 pt between blocks on `surface`, the soft twig leaf behind the top right corner, the
 system bar hidden for KiraNavBar. The boards' 34 pt under the content is the home indicator's
 safe area, so nothing is added to it; the column is at least the screen's height, so a Spacer
 pins a screen's buttons to the bottom (the boards' `margin-top: auto`).
 */
import SwiftUI

struct PlansScreenFrame<Content: View>: View {
    /** Where the leaf sits: 22 pt above the nav bar (most boards) or 54 pt (Beasiswa Kira's). */
    enum Leaf {
        case standard(size: CGFloat = 140)
        case high
    }

    private let leaf: Leaf
    private let content: Content

    init(leaf: Leaf = .standard(), @ViewBuilder content: () -> Content) {
        self.leaf = leaf
        self.content = content()
    }

    var body: some View {
        GeometryReader { screen in
            ScrollView {
                VStack(alignment: .leading, spacing: KiraSpacing.space4) { content }
                    .padding(.horizontal, KiraSpacing.screen)
                    .padding(.top, KiraSpacing.space2)
                    .frame(maxWidth: .infinity, minHeight: screen.size.height, alignment: .top)
                    .background(alignment: .topTrailing) { leafView }
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }
}

extension PlansScreenFrame {
    @ViewBuilder fileprivate var leafView: some View {
        switch leaf {
        case .standard(let size):
            KiraLeaf(.twig, tone: .soft, size: size, isFlipped: true).offset(x: 36, y: -22).accessibilityHidden(true)
        case .high:
            KiraLeaf(.twig, tone: .soft, size: 140, isFlipped: true).offset(x: 46, y: -54).accessibilityHidden(true)
        }
    }
}

/** A board's page header: the display title and one muted line under it. */
struct PlansHeader: View {
    private let title: LocalizedStringResource
    private let subtitle: LocalizedStringResource
    private let lineHeight: CGFloat

    /** The title is 26 pt on 31 pt lines (the Bayar boards); Ajukan Beasiswa's lines are 32 pt. */
    init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource, lineHeight: CGFloat = 31) {
        self.title = title
        self.subtitle = subtitle
        self.lineHeight = lineHeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            PlansDisplayTitle(title, size: 26, lineHeight: lineHeight)
            Text(subtitle).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
        }
        .padding(.horizontal, KiraSpacing.space1)
    }
}

/**
 A board's display title in Plus Jakarta Sans ExtraBold on lines 6 pt taller than its size, tracked
 −0.025 em (Paket Kira's headline: −0.02 em).
 */
struct PlansDisplayTitle: View {
    private let title: LocalizedStringResource
    private let size: CGFloat
    private let lineHeight: CGFloat
    private let tracking: CGFloat
    private let color: Color

    init(
        _ title: LocalizedStringResource, size: CGFloat, lineHeight: CGFloat? = nil, tracking: CGFloat = 0.025,
        color: Color = .ink
    ) {
        self.title = title
        self.size = size
        self.lineHeight = lineHeight ?? size + 6
        self.tracking = tracking
        self.color = color
    }

    var body: some View {
        Text(title)
            .font(KiraFont.display(size, .heavy, relativeTo: .title))
            .kiraLineHeight(lineHeight, size: size, natural: 1.26, relativeTo: .title)
            .tracking(-size * tracking)
            .foregroundStyle(color)
            .accessibilityAddTraits(.isHeader)
    }
}

/**
 Two buttons side by side, the secondary at 1 and the primary at 1.3 of the width (the boards'
 `minmax(0, 1fr) minmax(0, 1.3fr)`); stacked, primary on top, at the accessibility text sizes.
 */
struct PlansButtonRow: View {
    let secondary: KiraButton
    let primary: KiraButton
    /** Turns off the primary alone: the secondary (Batal) always works. */
    var isPrimaryDisabled = false
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(spacing: KiraSpacing.space2) {
                primary.block().disabled(isPrimaryDisabled)
                secondary.block()
            }
        } else {
            WeightedRow(weights: [1, 1.3], spacing: 10) {
                secondary.block()
                primary.block().disabled(isPrimaryDisabled)
            }
        }
    }
}
