import Foundation

/**
 A rupiah amount typed in a quiz field (ONB-10 and the steps after it): the person types digits
 only, the field groups them with dots as they go ("7.500.000"), and ",00" sits beside the box.
 */

/** Reads and groups whole rupiah typed into a field. */
package enum AmountInput {
    /** The most digits a field keeps: up to Rp999.999.999.999. */
    package static let maximumDigits = 12

    /** The whole rupiah in `text`, ignoring anything but digits; nil when there are none. */
    package static func value(of text: String) -> Int? {
        let digits = DigitCode.digits(in: text, length: maximumDigits)
        return Int(digits)
    }

    /** `text` as the field shows it: its digits grouped with dots, or empty when it has none. */
    package static func grouped(_ text: String) -> String {
        guard let value = value(of: text) else { return "" }
        return RupiahFormatStyle().part(.integer).format(Decimal(value))
    }

    /** An amount as the field shows it when it opens filled, or empty for none. */
    package static func text(for value: Int?) -> String {
        guard let value else { return "" }
        return grouped(String(value))
    }
}
