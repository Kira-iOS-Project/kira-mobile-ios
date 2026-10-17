import Foundation

/** A line's label and the amount at its end. */
struct TrailingAmount {
    /** What is printed before the amount. */
    let label: String
    /** The amount in rupiah. */
    let value: Double
    /** Whether a minus sits before it. */
    let minus: Bool
}

/**
 The amount at the end of a receipt line as OCR reads it: "72.000", "Rp 72.000", "72.000,00",
 "72.000,-", "25rb", "25k", "IDR 72.000", and digits OCR read as letters ("25.OOO", "1O.000").
 */
package enum ReceiptAmountText {
    /**
     `line` with the letters OCR mistakes for digits put back where they sit among digits and
     separators: O or o as 0, l or I as 1, in a run that already holds a digit.
     */
    static func repaired(_ line: String) -> String {
        line.replacing(/[0-9OoIl][0-9OoIl.,]*[0-9OoIl]/) { match in
            let run = String(match.output)
            guard run.contains(where: \.isASCIIDigit), run.filter(\.isLetter).count < run.count else { return run }
            return String(run.map { ["O": "0", "o": "0", "I": "1", "l": "1"][$0] ?? $0 })
        }
    }

    /**
     The label before the line's trailing amount, its value in rupiah, and whether a minus sits
     before it; nil when the line does not end in an amount.
     */
    static func trailingAmount(of line: String) -> TrailingAmount? {
        let pattern =
            #/
            ^ (?<label> .*?) [\s:=]* (?<minus> -)? \s* (?: (?: [Rr][Pp] | IDR ) \.? \s*)?
            (?:
                (?<short> \d+ (?: [.,]\d{1,2})?) \s* (?: [Rr][Bb] | [Rr]ibu | [Kk]) \.?
                | (?<amount> \d{1,3} (?: [.,]\d{3})+ (?: [.,]\d{2})? | \d+ (?: [.,]\d{2})?) (?: [.,]- )?
            ) $
            /#
        guard let match = line.wholeMatch(of: pattern) else { return nil }
        let label = String(match.label).trimmingCharacters(in: .whitespaces)
        if let short = match.short, let value = NumberText.value(of: String(short)) {
            return TrailingAmount(label: label, value: value * 1000, minus: match.minus != nil)
        }
        guard let amount = match.amount, let value = NumberText.value(of: String(amount)) else { return nil }
        return TrailingAmount(label: label, value: value, minus: match.minus != nil)
    }
}
