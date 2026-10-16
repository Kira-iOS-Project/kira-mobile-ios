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

    package init(storeName: String?, printedAt: ReceiptDate?, items: [ReceiptLine], total: Int) {
        self.storeName = storeName
        self.printedAt = printedAt
        self.items = items
        self.total = total
    }

    /** Whether the items add up to the total, as the API checks (RECEIPT_TOTAL_MISMATCH). */
    package var isBalanced: Bool { items.map(\.amount).reduce(0, +) == total }
}

/** One bought item. */
package struct ReceiptLine: Equatable, Sendable {
    package let name: String
    package var amount: Int

    package init(name: String, amount: Int) {
        self.name = name
        self.amount = amount
    }
}

/** A date printed on a receipt ("15-10-2026 12:58"), in the store's own time (WIB). */
package struct ReceiptDate: Equatable, Sendable {
    package let day: Int
    package let month: Int
    package let year: Int
    package let hour: Int?
    package let minute: Int?

    package init(day: Int, month: Int, year: Int, hour: Int? = nil, minute: Int? = nil) {
        self.day = day
        self.month = month
        self.year = year
        self.hour = hour
        self.minute = minute
    }
}
