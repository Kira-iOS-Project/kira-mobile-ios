import Foundation

/**
 The text field of a yearly interest rate ("Bunga per Tahun"): digits with at most one decimal
 comma and two decimals, from 0 to 300 percent, which is the most the backend accepts.
 */
package enum PercentInput {
    /** The highest rate the backend accepts, in percent. */
    package static let maximum = 300.0

    /** `text` as the field keeps it: up to three whole digits, then a comma and up to two decimals. */
    package static func cleaned(_ text: String) -> String {
        var whole = ""
        var decimals = ""
        var hasSeparator = false
        for character in text {
            if character == "," || character == "." {
                hasSeparator = true
            } else if ("0"..."9").contains(character) {
                if hasSeparator, decimals.count < 2 {
                    decimals.append(character)
                } else if !hasSeparator, whole.count < 3 {
                    whole.append(character)
                }
            }
        }
        return hasSeparator ? whole + "," + decimals : whole
    }

    /** The rate in `text`, or nil when it is empty or above `maximum`. */
    package static func value(of text: String) -> Double? {
        let cleaned = cleaned(text).replacingOccurrences(of: ",", with: ".")
        guard let value = Double(cleaned.hasSuffix(".") ? cleaned + "0" : cleaned), value <= maximum else {
            return nil
        }
        return value
    }

    /** A stored rate as the field shows it when it opens filled, or empty for none. */
    package static func text(for value: Double?) -> String {
        guard let value else { return "" }
        let hundredths = Int((value * 100).rounded())
        let whole = hundredths / 100
        let fraction = hundredths % 100
        if fraction == 0 { return String(whole) }
        let digits = fraction < 10 ? "0" + String(fraction) : String(fraction)
        return String(whole) + "," + (digits.hasSuffix("0") ? String(digits.prefix(1)) : digits)
    }
}
