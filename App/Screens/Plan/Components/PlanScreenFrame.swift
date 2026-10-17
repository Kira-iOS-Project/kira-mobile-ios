/**
 The frame the risk quiz, Hasil Kuis and Cek Legalitas boards share: a scrolling 16 pt column with
 16 pt between blocks on `surface`, the system bar hidden for KiraNavBar, and the column at least the
 screen's height so a Spacer pins the buttons to the bottom (the boards' `margin-top: auto`). The
 quiz draws the soft twig behind the top right corner; Hasil Kuis lays its scenery behind the card.
 */
import SwiftUI

struct PlanScreenFrame<Content: View, Backdrop: View>: View {
    @ViewBuilder let backdrop: () -> Backdrop
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { screen in
            ScrollView {
                VStack(alignment: .leading, spacing: KiraSpacing.space4) { content() }
                    .padding(.horizontal, KiraSpacing.screen)
                    .padding(.top, KiraSpacing.space2)
                    .padding(.bottom, KiraSpacing.space2)
                    .frame(maxWidth: .infinity, minHeight: screen.size.height, alignment: .top)
                    .background(alignment: .top) { backdrop().accessibilityHidden(true) }
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }
}

extension PlanScreenFrame where Backdrop == AnyView {
    /** The quiz's frame: the soft twig, flipped, 136 pt, past the top right corner. */
    init(@ViewBuilder content: @escaping () -> Content) {
        self.init(
            backdrop: {
                AnyView(
                    KiraLeaf(.twig, tone: .soft, size: 136, isFlipped: true)
                        .frame(maxWidth: .infinity, alignment: .trailing).offset(x: 40, y: -38))
            }, content: content)
    }
}

/** A board's display heading: Plus Jakarta Sans ExtraBold, tracked tight, and one muted line under it. */
struct PlanHeading: View {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    var size: CGFloat = 24
    var lineHeight: CGFloat = 30

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            Text(title)
                .font(KiraFont.display(size, .heavy, relativeTo: .title))
                .kiraLineHeight(lineHeight, size: size, natural: 1.26, relativeTo: .title)
                .tracking(-size * 0.02)
                .foregroundStyle(.ink)
                .accessibilityAddTraits(.isHeader)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, KiraSpacing.space1)
        .padding(.top, KiraSpacing.space2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/** Kembali at 1 and the primary at 1.3 of the width; stacked, primary on top, at the accessibility sizes. */
struct PlanButtonRow: View {
    let secondary: KiraButton
    let primary: KiraButton
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
