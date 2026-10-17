import APIClient
import Domain
import Foundation

@testable import Features

/** Portofolio's API answered from memory, recording what Tambah Aset sent. */
actor FakePortfolioService: PortfolioService {
    /** The board's day. */
    static let day = CalendarDay(year: 2026, month: 10, day: 1)
    /** Emas Batangan, Rp2.400.000. */
    /** A portfolio of Emas Batangan alone. */
    static var sample: Portfolio { portfolio([gold]) }
    static let gold = Asset(id: "gold", assetClass: .gold, name: "Emas Batangan", value: 2_400_000, valuedOn: day)

    private var portfolios: [Result<Portfolio, AppProblem>]
    private var saves: [Result<Void, AppProblem>]
    /** Every save, as (id or nil for a new asset, input). */
    private(set) var sent: [(id: String?, input: AssetInput)] = []

    /** Answers the loads with `portfolios` in turn (the last repeats) and the saves with `saves`. */
    init(
        portfolios: [Result<Portfolio, AppProblem>] = [.success(FakePortfolioService.sample)],
        saves: [Result<Void, AppProblem>] = []
    ) {
        self.portfolios = portfolios
        self.saves = saves
    }

    /** A portfolio of `assets` at 32% for 80 points. */
    static func portfolio(_ assets: [Asset]) -> Portfolio {
        Portfolio(
            assets: assets, total: assets.map(\.value).reduce(0, +), updatedOn: assets.isEmpty ? nil : day,
            debtToAsset: DebtToAssetImpact(percent: 32, points: 80, band: .healthy))
    }

    func portfolio() throws -> Portfolio {
        let answer = portfolios.count > 1 ? portfolios.removeFirst() : portfolios[0]
        return try answer.get()
    }

    func addAsset(_ input: AssetInput) throws -> Asset {
        try save(nil, input)
    }

    func updateAsset(id: String, _ input: AssetInput) throws -> Asset {
        try save(id, input)
    }

    private func save(_ id: String?, _ input: AssetInput) throws -> Asset {
        sent.append((id, input))
        if !saves.isEmpty { try saves.removeFirst().get() }
        return Asset(
            id: id ?? "new", assetClass: input.assetClass, name: input.name, value: input.value,
                valuedOn: input.valuedOn)
    }
}
