// A row that wraps: chips for quiz answers and filters flow onto as many lines as they need,
// each keeping its own width, instead of squeezing or truncating.
import SwiftUI

/// Lays its children left to right and wraps them onto new lines: chips.
struct KiraFlowRow: Layout {
    var spacing: CGFloat = KiraSpacing.space2

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        return CGSize(width: proposal.width ?? rows.width, height: rows.height)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        var origin = CGPoint(x: bounds.minX, y: bounds.minY)
        var lineHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if origin.x > bounds.minX, origin.x + size.width > bounds.maxX {
                origin = CGPoint(x: bounds.minX, y: origin.y + lineHeight + spacing)
                lineHeight = 0
            }
            subview.place(at: origin, proposal: ProposedViewSize(size))
            origin.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }

    private func arrange(width: CGFloat, subviews: Subviews) -> CGSize {
        var lineX: CGFloat = 0
        var lineY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var widest: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if lineX > 0, lineX + size.width > width {
                lineY += lineHeight + spacing
                lineX = 0
                lineHeight = 0
            }
            lineX += size.width + spacing
            widest = max(widest, lineX - spacing)
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: widest, height: lineY + lineHeight)
    }
}
