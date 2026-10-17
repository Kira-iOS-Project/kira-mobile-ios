/**
 One edit of a rupiah field (a keystroke, a paste, a deletion) applied and grouped within the same
 edit, so no later write-back can race the next keystroke and drop a digit ("7500000" typed fast
 once became "750.000"). The caret stays after the same digits it was after, whatever dots the
 grouping adds or removes. Offsets are UTF-16, as a text field counts them.
 */

/** A rupiah field's text and caret after one edit. */
package struct AmountEdit: Equatable, Sendable {
    /** The field's text, its digits grouped with dots ("7.500.000"), or empty. */
    package let text: String
    /** The caret, as a UTF-16 offset into `text`. */
    package let caret: Int

    /** A text and a caret. */
    package init(text: String, caret: Int) {
        self.text = text
        self.caret = caret
    }

    /**
     `text` with the UTF-16 range at `location` of `length` replaced by `replacement`, grouped. A
     deletion of only a dot deletes the digit before it too, so backspace always removes a digit.
     An edit that would pass `AmountInput.maximumDigits` leaves the field as it was.
     */
    package static func apply(to text: String, location: Int, length: Int, replacement: String) -> AmountEdit {
        let units = Array(text.utf16)
        var start = min(max(location, 0), units.count)
        let end = min(start + max(length, 0), units.count)
        let deletesOnlyDots = replacement.isEmpty && end > start && !units[start..<end].contains(where: isDigit)
        if deletesOnlyDots, let digit = units[..<start].lastIndex(where: isDigit) { start = digit }
        let proposed = Array(units[..<start]) + Array(replacement.utf16) + Array(units[end...])
        let digits = proposed.filter(isDigit)
        let kept = digits.drop { $0 == zero }
        let normalized = kept.isEmpty && !digits.isEmpty ? 1 : kept.count
        guard normalized <= AmountInput.maximumDigits else { return AmountEdit(text: text, caret: end) }
        let caret = start + replacement.utf16.count
        let typedBefore = proposed[..<caret].filter(isDigit).count
        let digitsBefore = max(typedBefore - (digits.count - normalized), 0)
        let grouped = AmountInput.grouped(String(decoding: proposed, as: UTF16.self))
        return AmountEdit(text: grouped, caret: offset(afterDigits: digitsBefore, in: grouped))
    }

    /**
     What the field shows when its binding changes: while it is typed in, its own text, which
     already holds every keystroke, so a binding that arrives late with an older value ("4.800"
     after "48.000" is on screen) can never take digits away; otherwise the binding's value, grouped
     (a form filled in, a reset).
     */
    package static func shown(current: String, binding: String, isEditing: Bool) -> String {
        isEditing ? current : AmountInput.grouped(binding)
    }

    /** "0" as a UTF-16 code unit. */
    private static let zero: UTF16.CodeUnit = 48

    private static func isDigit(_ unit: UTF16.CodeUnit) -> Bool {
        (48...57).contains(unit)
    }

    /** The UTF-16 offset just after the `count`th digit of `text`; 0 for none. */
    private static func offset(afterDigits count: Int, in text: String) -> Int {
        let positions = text.utf16.enumerated().filter { isDigit($0.element) }.map(\.offset)
        return positions.prefix(count).last.map { $0 + 1 } ?? 0
    }
}
