import Testing

@testable import Domain

@Suite("PortfolioShares")
struct PortfolioSharesTests {
    private let day = CalendarDay(year: 2026, month: 10, day: 1)

    private func asset(_ id: String, _ assetClass: AssetClass, _ value: Int) -> Asset {
        Asset(id: id, assetClass: assetClass, name: id, value: value, valuedOn: day)
    }

    @Test("the board's three assets read 38, 32 and 30 percent")
    func board() {
        let assets = [
            asset("a", .mutualFund, 3_000_000), asset("b", .governmentBond, 2_500_000), asset("c", .gold, 2_400_000),
        ]
        #expect(PortfolioShares.byAsset(assets) == ["a": 38, "b": 32, "c": 30])
        #expect(
            PortfolioShares.byClass(assets) == [
                ClassShare(assetClass: .mutualFund, percent: 38), ClassShare(assetClass: .governmentBond, percent: 32),
                ClassShare(assetClass: .gold, percent: 30),
            ])
    }

    @Test("three thirds add up to 100, and a class sums its assets in the order it first appears")
    func remainders() {
        let assets = [asset("a", .gold, 1), asset("b", .stock, 1), asset("c", .gold, 1), asset("d", .crypto, 0)]
        #expect(PortfolioShares.byAsset(assets).values.reduce(0, +) == 100)
        #expect(
            PortfolioShares.byClass(assets) == [
                ClassShare(assetClass: .gold, percent: 67), ClassShare(assetClass: .stock, percent: 33),
            ])
    }

    @Test("nothing of value is zero everywhere")
    func empty() {
        #expect(PortfolioShares.wholePercents([0, 0]) == [0, 0])
        #expect(PortfolioShares.byClass([]).isEmpty)
    }
}
