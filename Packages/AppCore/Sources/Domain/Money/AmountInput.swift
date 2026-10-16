/**
 What a person types into a rupiah field (the Field's "Rp" prefix and ",00" suffix): the quiz
 fields of Cek Kesehatan (ONB-10 and after) and the amount of a transaction being edited. Digits
 only, grouped with dots as they type ("7.500.000"); anything that is not a digit is dropped, so
 pasted "Rp18.000" reads the same.
 */
import Foundation

/** Reads and groups whole rupiah typed into a field. */
package enum AmountInput {
    /** The most digits a field keeps: up to Rp999.999.999.999. */
    package static let maximumDigits = 12

    /** The whole rupiah in `text`, ignoring anything but digits; nil when there are none, 0 for "0". */
    package static func value(of text: String) -> Int? {
        Int(DigitCode.digits(in: text, length: maximumDigits))
    }

    /** The amount of a transaction: like `value(of:)`, but nil for zero, which no transaction has. */
    package static func amount(_ text: String) -> Int? {
        guard let value = value(of: text), value > 0 else { return nil }
        return value
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
