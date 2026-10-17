/**
 The board's portfolio behind PortfolioService, for previews and `-KiraScreen` (debug only):
 Reksa Dana Pasar Uang, SBN Ritel and Emas Batangan, Rp7.900.000,00 in all, updated on 1 October
 2026, with Utang terhadap Aset at 32% for 80 points. `assets: []` is the empty portfolio;
 `failsLoad` and `failsSave` answer like a lost connection.
 */
import APIClient
import Domain
import Features

struct PreviewPortfolioService: PortfolioService {
    /** The board's three assets. */
    static let sampleAssets = [
        Asset(id: "mutual-fund", assetClass: .mutualFund, name: "Reksa Dana Pasar Uang", value: 3_000_000,
            valuedOn: day),
        Asset(id: "bond", assetClass: .governmentBond, name: "SBN Ritel", value: 2_500_000, valuedOn: day),
        Asset(id: "gold", assetClass: .gold, name: "Emas Batangan", value: 2_400_000, valuedOn: day),
    ]
    private static let day = CalendarDay(year: 2026, month: 10, day: 1)

    var assets = Self.sampleAssets
    var failsLoad = false
    var failsSave = false

    func portfolio() throws -> Portfolio {
        if failsLoad { throw AppProblem.connectionLost }
        var total = 0
        for asset in assets { total += asset.value }
        return Portfolio(
            assets: assets, total: total, updatedOn: assets.isEmpty ? nil : Self.day,
            debtToAsset: DebtToAssetImpact(percent: 32, points: 80, band: .healthy))
    }

    func addAsset(_ input: AssetInput) throws -> Asset {
        try save(id: "new", input)
    }

    func updateAsset(id: String, _ input: AssetInput) throws -> Asset {
        try save(id: id, input)
    }

    private func save(id: String, _ input: AssetInput) throws -> Asset {
        if failsSave { throw AppProblem.connectionLost }
        return Asset(id: id, assetClass: input.assetClass, name: input.name, value: input.value,
            valuedOn: input.valuedOn)
    }
}
