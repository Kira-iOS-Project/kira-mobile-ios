/**
 The design system's `text-wrap: balance` (the dialog title, the sheet subtitle, and the boards'
 headings): a text keeps the number of lines it needs at the width it is
 offered, but takes the narrowest width that still fits in those lines, so its lines come out
 about even ("Catatan keuanganmu / hanya terbuka untukmu.", not a lone word on the last line).
 */
import SwiftUI

/** Lays out its one subview at the narrowest width that keeps the line count of the full width. */
struct BalancedLines: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        guard let text = subviews.first else { return .zero }
        let width = balancedWidth(of: text, in: proposal.width)
        return text.sizeThatFits(ProposedViewSize(width: width, height: nil))
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()
    ) {
        guard let text = subviews.first else { return }
        let width = balancedWidth(of: text, in: proposal.width)
        text.place(
            at: CGPoint(x: bounds.midX, y: bounds.minY), anchor: .top,
            proposal: ProposedViewSize(width: width, height: nil))
    }

    /** Halves the range between half the width and the full width until it is within a point. */
    private func balancedWidth(of text: LayoutSubview, in offered: CGFloat?) -> CGFloat? {
        guard let offered, offered.isFinite else { return offered }
        let full = text.sizeThatFits(ProposedViewSize(width: offered, height: nil))
        var low = offered / 2
        var high = min(offered, full.width)
        while high - low > 1 {
            let middle = (low + high) / 2
            if text.sizeThatFits(ProposedViewSize(width: middle, height: nil)).height > full.height {
                low = middle
            } else {
                high = middle
            }
        }
        return ceil(high)
    }
}

extension View {
    /** Wraps a multi-line text into lines of about even length, as `text-wrap: balance` does. */
    func balancedLines() -> some View {
        BalancedLines { self }
    }
}
