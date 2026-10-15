// A row whose children share the width by weight, like CSS grid's `fr` columns: the Kira Score
// meter's zones (40, 40, 20) and the NextStepCard's actions (1 and 1.3).
import SwiftUI

/// Lays its children out left to right, each as wide as its share of `weights`.
struct WeightedRow: Layout {
    let weights: [CGFloat]
    var spacing: CGFloat = 0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let widths = columnWidths(total: proposal.width ?? idealWidth(subviews), count: subviews.count)
        var height: CGFloat = 0
        for (subview, width) in zip(subviews, widths) {
            height = max(height, subview.sizeThatFits(ProposedViewSize(width: width, height: proposal.height)).height)
        }
        return CGSize(width: proposal.width ?? idealWidth(subviews), height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        var originX = bounds.minX
        for (subview, width) in zip(subviews, columnWidths(total: bounds.width, count: subviews.count)) {
            subview.place(
                at: CGPoint(x: originX, y: bounds.midY), anchor: .leading,
                proposal: ProposedViewSize(width: width, height: bounds.height))
            originX += width + spacing
        }
    }

    private func columnWidths(total: CGFloat, count: Int) -> [CGFloat] {
        let used = Array(weights.prefix(count))
        let sum = used.reduce(0, +)
        let free = max(total - spacing * CGFloat(max(count - 1, 0)), 0)
        return used.map { sum > 0 ? free * $0 / sum : 0 }
    }

    private func idealWidth(_ subviews: Subviews) -> CGFloat {
        var width = spacing * CGFloat(max(subviews.count - 1, 0))
        for subview in subviews {
            width += subview.sizeThatFits(.unspecified).width
        }
        return width
    }
}
