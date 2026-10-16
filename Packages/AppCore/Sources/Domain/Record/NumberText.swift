/**
 Reads a number written with Indonesian or English separators: "25.000", "25,000", "25.000,00",
 "1,5", "2.500.000". Chat and receipts share it.
 */
package enum NumberText {
    /**
     The value of `text`, or nil when it is not a number. One separator followed by one, two or
     more than three digits is a decimal mark ("1,5", "25,00"); separators followed by groups of
     three digits are thousands ("25.000"); a last group of two digits after thousands is the
     cents of a receipt ("72.000,00"), which rupiah drop.
     */
    package static func value(of text: String) -> Double? {
        let groups = text.split(separator: /[.,]/, omittingEmptySubsequences: false).map(String.init)
        guard !text.isEmpty, groups.allSatisfy({ !$0.isEmpty && $0.allSatisfy(\.isASCIIDigit) }) else {
            return nil
        }
        guard groups.count > 1 else { return Double(text) }
        let tail = groups.dropFirst()
        if groups.count == 2, let last = tail.last, last.count != 3 {
            return Double("\(groups[0]).\(last)")
        }
        let thousands = tail.last?.count == 2 ? Array(tail.dropLast()) : Array(tail)
        guard groups[0].count <= 3, thousands.allSatisfy({ $0.count == 3 }) else { return nil }
        return Double(groups[0] + thousands.joined())
    }
}

extension Character {
    /** An ASCII digit, 0 to 9: the digits receipts and chat amounts use. */
    var isASCIIDigit: Bool { isASCII && isNumber }
}
