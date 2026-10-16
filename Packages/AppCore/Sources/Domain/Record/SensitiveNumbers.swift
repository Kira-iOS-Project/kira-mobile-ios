/**
 Masks account and card numbers before any receipt text leaves the device (CAT-05: "Nomor
 rekening dan kartu di struk disamarkan"). Only the text is kept, and never a long number in full.
 */
package enum SensitiveNumbers {
    /**
     `text` with every run of ten digits or more (single spaces or dashes between them allowed)
     replaced by "••••" and its last four digits:
     "Debit 4111 1111 1111 1234" reads "Debit ••••1234".
     */
    package static func masked(_ text: String) -> String {
        text.replacing(/\d(?:[ \-]?\d){9,}/) { match in
            let digits = match.output.filter(\.isASCIIDigit)
            return "••••" + digits.suffix(4)
        }
    }
}
