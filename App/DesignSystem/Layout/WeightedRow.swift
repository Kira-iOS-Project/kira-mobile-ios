/**
 A row whose children share the width by weight, like CSS grid's `minmax(max-content, Nfr)`
 columns: the Kira Score meter's zones (40, 40, 20) and the button rows the boards draw at 1 and 1.3.
 A child is never narrower than its ideal width, so a label stays on one line where the board keeps
 it there; the others share what is left. When even the ideal widths do not fit, each child gets
 its share of the row in proportion to its ideal width.
 */
import SwiftUI

/** Lays its children out left to right, each as wide as its share of `weights`, never below its ideal width. */
struct WeightedRow: Layout {
    let weights: [CGFloat]
    var spacing: CGFloat = 0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let widths = columnWidths(total: proposal.width ?? idealWidth(subviews), subviews: subviews)
        var height: CGFloat = 0
        for (subview, width) in zip(subviews, widths) {
            height = max(height, subview.sizeThatFits(ProposedViewSize(width: width, height: proposal.height)).height)
        }
        return CGSize(width: proposal.width ?? idealWidth(subviews), height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        var originX = bounds.minX
        for (subview, width) in zip(subviews, columnWidths(total: bounds.width, subviews: subviews)) {
            subview.place(
                at: CGPoint(x: originX, y: bounds.midY), anchor: .leading,
                proposal: ProposedViewSize(width: width, height: bounds.height))
            originX += width + spacing
        }
    }

    private func columnWidths(total: CGFloat, subviews: Subviews) -> [CGFloat] {
        let used = Array(weights.prefix(subviews.count))
        let floors = subviews.prefix(used.count).map { $0.sizeThatFits(.unspecified).width }
        let free = max(total - spacing * CGFloat(max(used.count - 1, 0)), 0)
        let floorSum = floors.reduce(0, +)
        if floorSum >= free {
            return floors.map { floorSum > 0 ? free * $0 / floorSum : 0 }
        }
        return Self.share(free, weights: used, floors: floors)
    }

    /**
     CSS grid's flexible lengths: a column whose share falls below its floor keeps the floor, and the
     rest is shared again among the others until every share clears its floor.
     */
    private static func share(_ free: CGFloat, weights: [CGFloat], floors: [CGFloat]) -> [CGFloat] {
        var widths = [CGFloat?](repeating: nil, count: weights.count)
        var remaining = free
        while true {
            let open = widths.indices.filter { widths[$0] == nil }
            let weightSum = open.reduce(0) { $0 + weights[$1] }
            guard weightSum > 0 else { break }
            let unit = remaining / weightSum
            let tooNarrow = open.filter { weights[$0] * unit < floors[$0] }
            guard !tooNarrow.isEmpty else {
                for index in open { widths[index] = weights[index] * unit }
                break
            }
            for index in tooNarrow {
                widths[index] = floors[index]
                remaining -= floors[index]
            }
        }
        return widths.enumerated().map { $1 ?? floors[$0] }
    }

    private func idealWidth(_ subviews: Subviews) -> CGFloat {
        var width = spacing * CGFloat(max(subviews.count - 1, 0))
        for subview in subviews {
            width += subview.sizeThatFits(.unspecified).width
        }
        return width
    }
}
