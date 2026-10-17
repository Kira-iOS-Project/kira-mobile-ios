import Foundation

/**
 The four ranges of the fifth question (REN-06e), cut from the monthly income at 5%, 10% and 20%:
 up to 5%, 5 to 10%, 10 to 20%, and more than 20%. At Rp7.500.000,00 the cuts are Rp375.000,00,
 Rp750.000,00 and Rp1.500.000,00, as the board writes them.
 */
package struct MonthlyDepositRanges: Hashable, Sendable {
    /** 5% of the income: the top of the first range. */
    package let low: Decimal
    /** 10% of the income. */
    package let middle: Decimal
    /** 20% of the income: the bottom of the last range. */
    package let high: Decimal

    /** The cuts of `income`; a negative income counts as none. */
    package init(income: Decimal) {
        let base = max(income, 0)
        low = Self.percent(5, of: base)
        middle = Self.percent(10, of: base)
        high = Self.percent(20, of: base)
    }

    /** `rate` percent of `base`, rounded to the cent as rupiah are written. */
    private static func percent(_ rate: Decimal, of base: Decimal) -> Decimal {
        var exact = base * rate / 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &exact, 2, .plain)
        return rounded
    }
}
