/**
 The percentages Portofolio shows, computed on the device from the values (REN-10: "Persentase dan
 komposisi dihitung mesin"): each asset's share of the total ("38% dari total") and each class's
 share for the composition bar. Whole percentages that always add up to 100, by the largest
 remainder, so three thirds read 34, 33 and 33 rather than 33 three times.
 */
package enum PortfolioShares {
    /** Each asset's whole percentage of the total, by id. */
    package static func byAsset(_ assets: [Asset]) -> [String: Int] {
        let percents = wholePercents(assets.map(\.value))
        return Dictionary(uniqueKeysWithValues: zip(assets.map(\.id), percents))
    }

    /**
     The classes the assets hold, each with its whole percentage of the total, in the order of the
     first asset of each class; classes worth nothing are left out.
     */
    package static func byClass(_ assets: [Asset]) -> [ClassShare] {
        var order: [AssetClass] = []
        var totals: [AssetClass: Int] = [:]
        for asset in assets where asset.value > 0 {
            if totals[asset.assetClass] == nil { order.append(asset.assetClass) }
            totals[asset.assetClass, default: 0] += asset.value
        }
        let percents = wholePercents(order.map { totals[$0] ?? 0 })
        return zip(order, percents).map { ClassShare(assetClass: $0, percent: $1) }
    }

    /** Whole percentages of `values` adding up to 100 (all zeros when the values add up to nothing). */
    static func wholePercents(_ values: [Int]) -> [Int] {
        let total = values.reduce(0, +)
        guard total > 0 else { return values.map { _ in 0 } }
        let exact = values.map { Double($0) * 100 / Double(total) }
        var whole = exact.map { Int($0.rounded(.down)) }
        let byRemainder = exact.indices.sorted { exact[$0] - Double(whole[$0]) > exact[$1] - Double(whole[$1]) }
        for index in byRemainder.prefix(100 - whole.reduce(0, +)) { whole[index] += 1 }
        return whole
    }
}

/** One class's share of the portfolio. */
package struct ClassShare: Hashable, Sendable {
    /** The class. */
    package let assetClass: AssetClass
    /** Its whole percentage of the total. */
    package let percent: Int

    /** A share. */
    package init(assetClass: AssetClass, percent: Int) {
        self.assetClass = assetClass
        self.percent = percent
    }
}
