import Foundation

/** A percent typed in a goal form ("6,50" or "5"), read as a fraction (0.065). */
package enum RateInput {
    /** The fraction `text` means; nil when it is empty or not a number. */
    package static func rate(_ text: String) -> Double? {
        let normalized = text.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")
        guard let percent = Double(normalized.trimmingCharacters(in: .whitespaces)), percent >= 0 else { return nil }
        return percent / 100
    }

    /** A whole count typed in a field ("5" years); nil when it is not one, or not above zero. */
    package static func count(_ text: String) -> Int? {
        guard let value = Int(text.filter(\.isNumber)), value > 0 else { return nil }
        return value
    }
}
