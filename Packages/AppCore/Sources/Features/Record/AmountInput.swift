/**
 The digits a person types into an amount (CAT-02, CAT-04: "Jumlah hanya angka; ,00 ditambahkan
 saat simpan"). Anything but a digit is dropped, and the field shows the digits grouped by
 thousands the Indonesian way ("18.000"), the same in every region, like `RupiahFormatStyle`.
 */
package enum AmountInput {
    /** Twelve digits: Rp999.999.999.999,00, more than any one transaction. */
    static let maximumDigits = 12

    /** The digits of `text`, without leading zeros, at most twelve. */
    package static func digits(of text: String) -> String {
        let digits = text.filter(\.isASCII).filter(\.isNumber).drop { $0 == "0" }
        return String(digits.prefix(maximumDigits))
    }

    /** `text`'s digits grouped by thousands with dots: "18000" is "18.000". */
    package static func grouped(_ text: String) -> String {
        var digits = Array(digits(of: text))
        var groups: [String] = []
        while digits.count > 3 {
            groups.insert(String(digits.suffix(3)), at: 0)
            digits.removeLast(3)
        }
        if !digits.isEmpty { groups.insert(String(digits), at: 0) }
        return groups.joined(separator: ".")
    }

    /** The whole rupiah `text` holds, or 0. */
    package static func value(of text: String) -> Int {
        Int(digits(of: text)) ?? 0
    }
}
