import Foundation
import Testing

@testable import Domain

@Suite("MonthlyDepositRanges")
struct MonthlyDepositRangesTests {
    @Test("the board's income cuts at Rp375.000,00, Rp750.000,00 and Rp1.500.000,00")
    func board() {
        let ranges = MonthlyDepositRanges(income: 7_500_000)
        #expect(ranges.low == 375_000 && ranges.middle == 750_000 && ranges.high == 1_500_000)
    }

    @Test("an odd income rounds each cut to the cent; a negative one counts as none")
    func rounding() throws {
        let ranges = MonthlyDepositRanges(income: Decimal(string: "1234567.89") ?? 0)
        #expect(ranges.low == Decimal(string: "61728.39"))
        #expect(ranges.middle == Decimal(string: "123456.79"))
        #expect(ranges.high == Decimal(string: "246913.58"))
        let none = MonthlyDepositRanges(income: -100)
        #expect(none.low == 0 && none.middle == 0 && none.high == 0)
    }
}
