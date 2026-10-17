/**
 Portofolio Manual (REN-10): the person's assets, their total, the last day one was updated, and
 the Utang terhadap Aset indicator they feed (`GET /assets`).
 */
package struct Portfolio: Hashable, Sendable {
    /** The assets, in the API's order. */
    package let assets: [Asset]
    /** Their total in whole rupiah. */
    package let total: Int
    /** The last day an asset was added or updated; nil without assets. */
    package let updatedOn: CalendarDay?
    /** The indicator the assets count in; nil before the first health check. */
    package let debtToAsset: DebtToAssetImpact?

    /** A portfolio. */
    package init(assets: [Asset], total: Int, updatedOn: CalendarDay?, debtToAsset: DebtToAssetImpact?) {
        self.assets = assets
        self.total = total
        self.updatedOn = updatedOn
        self.debtToAsset = debtToAsset
    }

    /** The asset of `id`, if the portfolio has it. */
    package func asset(id: String) -> Asset? {
        assets.first { $0.id == id }
    }
}

/** "Dampak ke Kira Score": debt as a percentage of assets, the indicator's points and its band. */
package struct DebtToAssetImpact: Hashable, Sendable {
    /** Total debt as a whole percentage of total assets. */
    package let percent: Int
    /** The indicator's points, 0 to 100. */
    package let points: Int
    /** The band of those points. */
    package let band: ScoreBand

    /** An impact. */
    package init(percent: Int, points: Int, band: ScoreBand) {
        self.percent = percent
        self.points = points
        self.band = band
    }
}
