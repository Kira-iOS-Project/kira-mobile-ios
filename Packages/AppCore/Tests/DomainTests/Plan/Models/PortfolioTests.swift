import Testing

@testable import Domain

@Suite("Portfolio")
struct PortfolioTests {
    @Test("finds an asset by its id")
    func assetById() {
        let day = CalendarDay(year: 2026, month: 10, day: 1)
        let gold = Asset(id: "gold", assetClass: .gold, name: "Emas", value: 1, valuedOn: day)
        let portfolio = Portfolio(
            assets: [gold], total: 1, updatedOn: day,
            debtToAsset: DebtToAssetImpact(percent: 0, points: 100, band: .healthy))
        #expect(portfolio.asset(id: "gold") == gold)
        #expect(portfolio.asset(id: "gone") == nil)
        let input = AssetInput(assetClass: .gold, name: "Emas", value: 1, valuedOn: day)
        #expect(input.assetClass == gold.assetClass && input.value == gold.value)
    }
}
