/**
 The frame of the Kira Peduli boards: a scrolling 16 pt column with 20 pt between blocks on
 `surface`, the soft twig behind the top right corner and, on Kira Peduli, a soft pandan leaf at
 the bottom left; the system bar hidden for KiraNavBar. The column is at least the screen's
 height, so a Spacer pins a screen's buttons to the bottom (the boards' `margin-top: auto`).
 */
import SwiftUI

struct CareScreenFrame<Content: View>: View {
    private let twigSize: CGFloat
    private let showsPandan: Bool
    private let content: Content

    init(twigSize: CGFloat = 140, showsPandan: Bool = false, @ViewBuilder content: () -> Content) {
        self.twigSize = twigSize
        self.showsPandan = showsPandan
        self.content = content()
    }

    var body: some View {
        GeometryReader { screen in
            ScrollView {
                VStack(alignment: .leading, spacing: KiraSpacing.space5) { content }
                    .padding(.horizontal, KiraSpacing.screen)
                    .padding(.top, KiraSpacing.space2)
                    .padding(.bottom, KiraSpacing.space2)
                    .frame(maxWidth: .infinity, minHeight: screen.size.height, alignment: .top)
                    .background(alignment: .topTrailing) {
                        /** The boards' `top: 34px; right: -38px`. */
                        KiraLeaf(.twig, tone: .soft, size: twigSize, isFlipped: true)
                            .offset(x: 38, y: -28).accessibilityHidden(true)
                    }
                    .background(alignment: .bottomLeading) {
                        if showsPandan {
                            /** `bottom: -18px; left: -44px`. */
                            KiraLeaf(.pandan, tone: .soft, size: 130).offset(x: -44, y: 18).accessibilityHidden(true)
                        }
                    }
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }
}
