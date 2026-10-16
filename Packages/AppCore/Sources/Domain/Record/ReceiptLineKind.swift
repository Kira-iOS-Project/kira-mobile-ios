import Foundation

/** What one printed line of a receipt is. */
enum ReceiptLineKind: Equatable {
    /** A label with an amount at its end: an item, or a total, a payment or a discount. */
    case priced(label: String, amount: Int)
    /** A quantity line under an item's name: "1 x 72.000 72.000". */
    case quantity(amount: Int)
    /** Text without an amount: the store, the address, or an item's name before its quantity line. */
    case text(String)
    /** Nothing to read: a rule, a time, a number on its own. */
    case blank

    /** The trailing amount of a line, with an optional "Rp" and an optional minus before it. */
    private static var pricedLine: Regex<(Substring, label: Substring, minus: Substring?, amount: Substring)> {
        /^(?<label>.*?)[\s:=]*(?<minus>-)?\s*(?:[Rr][Pp]\.?\s*)?(?<amount>\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?|\d+(?:[.,]\d{2})?)$/
    }

    /** A quantity: "2 x", "2x", "@", "2 pcs x". */
    private static var quantityLabel: Regex<Substring> { /^\d+\s*(?:pcs|buah|bh)?\s*[xX@]/ }

    /** Reads one line, already trimmed. */
    static func of(_ line: String) -> ReceiptLineKind {
        guard let match = line.wholeMatch(of: pricedLine), let value = NumberText.value(of: String(match.amount))
        else {
            return line.contains(where: \.isLetter) ? .text(line) : .blank
        }
        let label = String(match.label).trimmingCharacters(in: .whitespaces)
        /** Below Rp100 a trailing number is a street number, a quantity or a clock's minutes. */
        guard value >= 100 else { return line.contains(where: \.isLetter) ? .text(line) : .blank }
        let amount = Int(value.rounded()) * (match.minus == nil ? 1 : -1)
        if label.firstMatch(of: quantityLabel) != nil { return .quantity(amount: abs(amount)) }
        return label.contains(where: \.isLetter) ? .priced(label: label, amount: amount) : .blank
    }
}

/** The words that tell a receipt's totals, payments and discounts from its items. */
enum ReceiptWords {
    static let totals: Set<String> = ["total", "jumlah", "grand total", "total belanja", "total bayar"]
    static let subtotals: Set<String> = ["subtotal", "sub total", "total item", "total qty", "jumlah item"]
    static let payments: Set<String> = [
        "tunai", "cash", "kembali", "kembalian", "change", "debit", "kredit", "credit", "kartu", "card",
        "bayar", "dibayar", "qris", "ovo", "gopay", "dana", "shopeepay", "edc", "visa", "mastercard",
        "transfer", "pembayaran", "payment",
    ]
    static let discounts: Set<String> = ["diskon", "disc", "discount", "potongan", "hemat", "voucher", "promo"]
    /** Head lines that are not the store's name. */
    static let notStore: [String] = ["jl", "jalan", "telp", "tel", "npwp", "no.", "www", "kasir", "struk"]

    /** The label in lower case with single spaces, as the sets compare it. */
    static func normalized(_ label: String) -> String {
        label.lowercased().split(whereSeparator: { !$0.isLetter }).joined(separator: " ")
    }

    /** Whether any word of `label` is in `words`, or the whole label is. */
    static func label(_ label: String, isIn words: Set<String>) -> Bool {
        let normal = normalized(label)
        return words.contains(normal) || normal.split(separator: " ").contains { words.contains(String($0)) }
    }
}
