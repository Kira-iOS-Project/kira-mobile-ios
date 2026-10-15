// The edges of a scrolling Kira screen. From iOS 26, a scroll view blurs and fades its content at
// its top and bottom edges (the scroll edge effect): that is glass, which Kira keeps for the dock alone, and it
// fades text near the edges, which Apple's accessibility audit then reads as low contrast. Kira hides
// the effect and lays a solid `surface` band behind the status bar instead.
import SwiftUI

extension View {
    /// A scrolling screen's edges: a solid `surface` band behind the status bar, and no blur at the
    /// top or the bottom.
    @ViewBuilder
    func kiraScrollEdges() -> some View {
        let banded = overlay(alignment: .top) {
            Color.clear.frame(height: 0).background(.surface, ignoresSafeAreaEdges: .top)
        }
        if #available(iOS 26, *) {
            banded.scrollEdgeEffectHidden(true, for: .vertical)
        } else {
            banded
        }
    }
}
