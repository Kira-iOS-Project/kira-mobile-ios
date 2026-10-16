/**
 Account and card numbers never leave the device whole (CAT-11: "Nomor rekening disamarkan"): any
 run of eight or more digits in a statement's description, single spaces or dashes allowed between
 them, becomes "••••" and its last four digits.
 */

/** Masks account and card numbers in free text. */
package enum AccountNumberMask {
    /** What stands for the hidden digits. */
    package static let mask = "••••"

    /** `text` with every long digit run masked: "TRF 1234567890 BUDI" → "TRF ••••7890 BUDI". */
    package static func masked(_ text: String) -> String {
        text.replacing(/\d(?:[ \-]?\d){7,}/) { match in
            mask + String(match.output.filter(\.isNumber).suffix(4))
        }
    }
}
