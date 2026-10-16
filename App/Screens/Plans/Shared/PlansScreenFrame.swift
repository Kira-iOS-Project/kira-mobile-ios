/**
 The frame the Paket, Langganan, Traktir Kira and Beasiswa Kira boards share: a scrolling 16 pt
 column with 16 pt between blocks on `surface`, the soft twig leaf behind the top right corner, the
 system bar hidden for KiraNavBar.
 */
import Domain
import SwiftUI

struct PlansScreenFrame<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) { content }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.top, KiraSpacing.space2)
                .padding(.bottom, 34)
                .background(alignment: .topTrailing) {
                    KiraLeaf(.twig, tone: .soft, size: 140, isFlipped: true)
                        .offset(x: 36, y: -22)
                        .accessibilityHidden(true)
                }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }
}

/** A board's page header: the display title and one muted line under it. */
struct PlansHeader: View {
    private let title: LocalizedStringResource
    private let subtitle: LocalizedStringResource
    private let size: CGFloat

    /** `size` is the title's: 26 on the Bayar boards, 28 on Paket and the plan details. */
    init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource, size: CGFloat = 26) {
        self.title = title
        self.subtitle = subtitle
        self.size = size
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            PlansDisplayTitle(title, size: size)
            Text(subtitle).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
        }
        .padding(.horizontal, KiraSpacing.space1)
    }
}

/** A board's display title in Plus Jakarta Sans ExtraBold, tracked −0.025 em. */
struct PlansDisplayTitle: View {
    private let title: LocalizedStringResource
    private let size: CGFloat
    private let color: Color

    init(_ title: LocalizedStringResource, size: CGFloat, color: Color = .ink) {
        self.title = title
        self.size = size
        self.color = color
    }

    var body: some View {
        Text(title)
            .font(KiraFont.display(size, .heavy, relativeTo: .title))
            .kiraLineHeight(size + 6, size: size, natural: 1.26, relativeTo: .title)
            .tracking(-size * 0.025)
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
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(spacing: KiraSpacing.space2) {
                primary.block()
                secondary.block()
            }
        } else {
            WeightedRow(weights: [1, 1.3], spacing: 10) {
                secondary.block()
                primary.block()
            }
        }
    }
}
