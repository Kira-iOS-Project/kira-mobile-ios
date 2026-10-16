/**
 Joins the pieces of text an OCR pass finds into the printed lines of a receipt. Vision reports
 "Beras 5 Kg" and "72.000,00" as two observations on one row; the receipt parser wants one line.
 */

/** One piece of recognised text, in coordinates from 0 to 1 with the origin at the top left. */
package struct TextFragment: Equatable, Sendable {
    /** The recognised text. */
    package let text: String
    /** Its left edge. */
    package let minX: Double
    /** Its vertical centre. */
    package let midY: Double
    /** Its height. */
    package let height: Double

    /** A piece of text at its place. */
    package init(text: String, minX: Double, midY: Double, height: Double) {
        self.text = text
        self.minX = minX
        self.midY = midY
        self.height = height
    }
}

/** Assembles recognised pieces into lines. */
package enum TextFragmentLines {
    /**
     The lines from top to bottom, each with its pieces from left to right. A piece joins a line
     when its centre is within half a line's height of the line's first piece.
     */
    package static func lines(of fragments: [TextFragment]) -> [String] {
        var rows: [[TextFragment]] = []
        for fragment in fragments.sorted(by: { $0.midY < $1.midY }) {
            if let first = rows.last?.first, isOnRow(fragment, of: first) {
                rows[rows.count - 1].append(fragment)
            } else {
                rows.append([fragment])
            }
        }
        return rows.map { row in
            row.sorted { $0.minX < $1.minX }.map(\.text).joined(separator: " ")
        }
    }

    /** Whether `fragment`'s centre is within half a line's height of `first`, the row's first piece. */
    private static func isOnRow(_ fragment: TextFragment, of first: TextFragment) -> Bool {
        abs(fragment.midY - first.midY) < max(first.height, fragment.height) / 2
    }
}
