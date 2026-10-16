/**
 What a person types into a rupiah field (the Field's "Rp" prefix and ",00" suffix): digits only,
 grouped with dots as they type ("18.000"), read back as whole rupiah. Anything that is not a digit
 is dropped, so pasted "Rp18.000" reads the same.
 */

/** Reads and groups the digits of a rupiah field. */
package enum AmountInput {
    /** The most digits a field keeps: up to Rp999.999.999.999. */
    package static let maximumDigits = 12

    /** The typed text with every non-digit dropped and the digits grouped by three: "18.000". */
    package static func grouped(_ text: String) -> String {
        let digits = digitsOf(text)
        var out = ""
        for (index, digit) in digits.enumerated() {
            if index > 0, (digits.count - index).isMultiple(of: 3) { out.append(".") }
            out.append(digit)
        }
        return out
    }

    /** The whole rupiah the text holds, or nil when it holds no digit. */
    package static func amount(_ text: String) -> Int? {
        Int(String(digitsOf(text)))
    }

    /** The grouped text of an amount, for a field opened on a saved value. */
    package static func text(for amount: Int) -> String {
        grouped(String(amount))
    }

    /** The digits of `text` without leading zeros, at most `maximumDigits` of them. */
    private static func digitsOf(_ text: String) -> [Character] {
        let digits = text.filter { $0.isASCII && $0.isNumber }.drop { $0 == "0" }
        return Array(digits.prefix(maximumDigits))
    }
}
