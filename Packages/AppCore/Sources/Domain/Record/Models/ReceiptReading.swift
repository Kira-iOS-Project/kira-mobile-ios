/** What a receipt says, read from the text the device recognised on it (CAT-06). */
package struct ReceiptReading: Equatable, Sendable {
    /** The store's name from the receipt's head, in Title Case, or nil when none was found. */
    package let storeName: String?
    /** The date and time printed on the receipt, or nil. */
    package let printedAt: ReceiptDate?
    /** The bought items with their amounts, discounts already taken off. */
    package let items: [ReceiptLine]
    /** The printed TOTAL, or the items' sum when the receipt prints none. */
    package let total: Int

    /** A reading of a receipt. */
    package init(storeName: String?, printedAt: ReceiptDate?, items: [ReceiptLine], total: Int) {
        self.storeName = storeName
        self.printedAt = printedAt
        self.items = items
        self.total = total
    }

    /** Whether the items add up to the total, as the API checks (RECEIPT_TOTAL_MISMATCH). */
    package var isBalanced: Bool { items.map(\.amount).reduce(0, +) == total }

    /**
     The reading with items that add up to the printed total, which always wins: what the items
     leave out (tax, service, a line OCR missed) becomes one line named `otherName`; items worth more
     than the total, or none at all, become that one line for the whole total. The person corrects
     the draft; the scan never fails on a total it could read.
     */
    package func balanced(otherName: String) -> ReceiptReading {
        let sum = items.map(\.amount).reduce(0, +)
        guard sum != total else { return self }
        let lines =
            sum < total && !items.isEmpty
            ? items + [ReceiptLine(name: otherName, amount: total - sum)]
            : [ReceiptLine(name: otherName, amount: total)]
        return ReceiptReading(storeName: storeName, printedAt: printedAt, items: lines, total: total)
    }
}

/** One bought item. */
package struct ReceiptLine: Equatable, Sendable {
    /** The item's name as printed. */
    package let name: String
    /** Whole rupiah, after any discount. */
    package var amount: Int

    /** An item and its amount. */
    package init(name: String, amount: Int) {
        self.name = name
        self.amount = amount
    }
}

/** A date printed on a receipt ("15-10-2026 12:58"), in the store's own time (WIB). */
package struct ReceiptDate: Equatable, Sendable {
    /** The day of the month. */
    package let day: Int
    /** The month, 1 to 12. */
    package let month: Int
    /** The year in four digits. */
    package let year: Int
    /** The hour, when printed. */
    package let hour: Int?
    /** The minute, when printed. */
    package let minute: Int?

    /** A printed date. */
    package init(day: Int, month: Int, year: Int, hour: Int? = nil, minute: Int? = nil) {
        self.day = day
        self.month = month
        self.year = year
        self.hour = hour
        self.minute = minute
    }
}
