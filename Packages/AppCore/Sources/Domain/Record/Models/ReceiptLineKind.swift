import Foundation

/** What one printed line of a receipt is. */
enum ReceiptLineKind: Equatable {
    /** A label with an amount at its end: an item, or a total, a payment or a discount. */
    case priced(label: String, amount: Int)
    /** A quantity line under an item's name: "1 x 72.000 72.000". */
    case quantity(amount: Int)
    /** Text without an amount: the store, the address, or an item's name before its quantity line. */
    case text(String)
    /** An amount alone on its line: OCR often puts "TOTAL" and "72.000" on two lines. */
    case amount(Int)
    /** Nothing to read: a rule, a time, a number on its own. */
    case blank

    /** A quantity: "2 x", "2x", "@", "2 pcs x". */
    private static var quantityLabel: Regex<Substring> { /^\d+\s*(?:pcs|buah|bh)?\s*[xX@]/ }

    /** Reads one line, already trimmed. */
    static func of(_ line: String) -> ReceiptLineKind {
        let line = ReceiptAmountText.repaired(line)
        guard let trailing = ReceiptAmountText.trailingAmount(of: line) else {
            return line.contains(where: \.isLetter) ? .text(line) : .blank
        }
        /** Below Rp100 a trailing number is a street number, a quantity or a clock's minutes. */
        let (label, value, minus) = (trailing.label, trailing.value, trailing.minus)
        guard value >= 100 else { return line.contains(where: \.isLetter) ? .text(line) : .blank }
        let amount = Int(value.rounded()) * (minus ? -1 : 1)
        if label.firstMatch(of: quantityLabel) != nil { return .quantity(amount: abs(amount)) }
        if label.contains(where: \.isLetter) { return .priced(label: label, amount: amount) }
        return label.isEmpty && !minus ? .amount(amount) : .blank
    }
}

/** The words that tell a receipt's totals, payments and discounts from its items. */
enum ReceiptWords {
    static let totals: Set<String> = [
        "total", "jumlah", "grand total", "total belanja", "total bayar", "total harga", "total tagihan",
        "jumlah bayar",
    ]
    /** Charges already in the total, never items: tax, service. */
    static let charges: Set<String> = [
        "ppn", "pajak", "tax", "pb1", "service", "svc", "layanan", "rounding", "pembulatan",
    ]
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

    /**
     Whether `label` names the total: a total phrase ("GRAND TOTAL", "TOTAL BAYAR"), or the word
     "total" or "jumlah" without a subtotal or a payment's change ("TOTAL ITEM", "KEMBALI").
     */
    static func isTotal(_ text: String) -> Bool {
        let normal = normalized(text)
        if totals.contains(normal) { return true }
        let words = normal.split(separator: " ").map(String.init)
        guard words.contains("total") || words.contains("jumlah") else { return false }
        return !label(text, isIn: subtotals) && !words.contains { ["kembali", "kembalian", "change"].contains($0) }
    }

    /** Whether any word of `label` is in `words`, or the whole label is. */
    static func label(_ label: String, isIn words: Set<String>) -> Bool {
        let normal = normalized(label)
        return words.contains(normal) || normal.split(separator: " ").contains { words.contains(String($0)) }
    }
}
