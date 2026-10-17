import Domain

/**
 Reads what is typed into a goal form: whole rupiah (grouped while typing, `AmountInput`), whole
 years or months, and a percent written with a comma or a dot ("4,5"), as a fraction (0.045).
 */
package enum GoalInput {
    /** Whole rupiah; nil when nothing is typed. */
    package static func rupiah(_ text: String) -> Int? {
        AmountInput.value(of: text)
    }

    /** A whole count above zero, such as years or months; nil otherwise. */
    package static func count(_ text: String) -> Int? {
        guard let value = Int(text.filter(\.isNumber)), value > 0 else { return nil }
        return value
    }

    /** A percent as a fraction, from 0 to 100%; nil when it is not a number in that range. */
    package static func percent(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value >= 0, value <= 100 else { return nil }
        return value / 100
    }
}
