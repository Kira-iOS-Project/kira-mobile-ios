/**
 Anggaran Pernikahan (REN-02d, board TujuanMenikah): the twelve rows of a detailed budget, three of
 them per guest (Katering, Suvenir, Undangan), and the three example budgets of the planner the
 calculators follow (Ekonomis Rp42.500.000,00, Standar Rp175.000.000,00, Sultan Rp775.000.000,00).
 */
package enum WeddingItemKind: String, CaseIterable, Hashable, Sendable {
    /** Venue / Gedung. */
    case venue
    /** MC. */
    case emcee
    /** Wedding Organizer. */
    case organizer
    /** Makeup. */
    case makeup
    /** Pakaian / Seragam. */
    case attire
    /** Mahar. */
    case dowry
    /** Dokumentasi. */
    case documentation
    /** Musik / Hiburan. */
    case music
    /** Dekorasi. */
    case decoration
    /** Katering, per guest. */
    case catering
    /** Suvenir, per guest. */
    case souvenir
    /** Undangan, per guest. */
    case invitation

    /** Whether the row is guests × a price each. */
    package var isPerGuest: Bool { self == .catering || self == .souvenir || self == .invitation }
}

/** One row of the budget: a fixed price, or guests × a price each. */
package struct WeddingItem: Hashable, Sendable {
    /** Which row. */
    package let kind: WeddingItemKind
    /** The price, or the price per guest; whole rupiah. */
    package var price: Int
    /** The guests, for a per-guest row; 1 otherwise. */
    package var guests: Int

    /** A row of `kind` at `price`, for `guests` when it is per guest. */
    package init(_ kind: WeddingItemKind, price: Int, guests: Int = 1) {
        self.kind = kind
        self.price = price
        self.guests = kind.isPerGuest ? guests : 1
    }

    /** The row's amount. */
    package var total: Int { price * guests }
}

/** The example budgets. */
package enum WeddingPreset: String, CaseIterable, Hashable, Sendable {
    /** Ekonomis. */
    case economical
    /** Standar. */
    case standard
    /** Sultan. */
    case lavish

    /** The preset's twelve rows, in the board's order. */
    package var items: [WeddingItem] {
        let prices: [Int]
        let guests: [Int]
        switch self {
        case .economical:
            prices = [6_000_000, 1_000_000, 5_000_000, 1_500_000, 5_000_000, 5_000_000, 2_000_000, 0, 5_000_000,
                40_000, 20_000, 20_000]
            guests = [150, 150, 150]
        case .standard:
            prices = [30_000_000, 3_000_000, 15_000_000, 10_000_000, 12_500_000, 10_000_000, 15_000_000, 10_000_000,
                35_000_000, 100_000, 6_000, 12_000]
            guests = [300, 250, 250]
        case .lavish:
            prices = [200_000_000, 15_000_000, 50_000_000, 50_000_000, 65_000_000, 50_000_000, 40_000_000, 25_000_000,
                80_000_000, 200_000, 100_000, 100_000]
            guests = [500, 500, 500]
        }
        return zip(WeddingItemKind.allCases, prices).enumerated().map { index, pair in
            WeddingItem(pair.0, price: pair.1, guests: index >= 9 ? guests[index - 9] : 1)
        }
    }
}
