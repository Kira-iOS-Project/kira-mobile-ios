/**
 Account and card numbers never leave the device whole: a scanned receipt's text (CAT-05: "Nomor
 rekening dan kartu di struk disamarkan") and a bank statement's descriptions (CAT-11: "Nomor
 rekening disamarkan") keep only a number's last four digits.
 */
package enum SensitiveNumbers {
    /** What stands for the hidden digits. */
    package static let mask = "••••"

    /**
     `text` with every run of `minimumDigits` digits or more (single spaces or dashes between them
     allowed) replaced by "••••" and its last four digits: "Debit 4111 1111 1111 1234" reads
     "Debit ••••1234". Receipts mask from ten digits, so a cashier's short phone-like codes stay;
     bank statements from eight, as their descriptions carry no other long numbers.
     */
    package static func masked(_ text: String, minimumDigits: Int = 10) -> String {
        text.replacing(/\d(?:[ \-]?\d)*/) { match in
            let digits = match.output.filter(\.isASCIIDigit)
            return digits.count >= minimumDigits ? mask + String(digits.suffix(4)) : String(match.output)
        }
    }
}
