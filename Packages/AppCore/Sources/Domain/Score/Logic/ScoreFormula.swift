/**
 "Gimana Ngitungnya?" (ONB-13b): the Kira Score is the plain average of the six indicators'
 points, rounded half up ("(25 + 45 + 70 + 50 + 80 + 100) ÷ 6 = 61,7 → dibulatkan 62").
 */

/** The working behind a score, as the accordion shows it. */
package struct ScoreFormula: Hashable, Sendable {
    /** Each indicator's points, in the report's order. */
    package let points: [Int]

    /** The working of `report`, from its indicators. */
    package init(_ report: ScoreReport) {
        points = report.indicators.map(\.points)
    }

    /** The average to one decimal (61.7), or 0 without indicators. */
    package var average: Double {
        guard !points.isEmpty else { return 0 }
        let mean = Double(points.reduce(0, +)) / Double(points.count)
        return (mean * 10).rounded() / 10
    }

    /** The average rounded half up to a whole score. */
    package var rounded: Int {
        guard !points.isEmpty else { return 0 }
        return Int((Double(points.reduce(0, +)) / Double(points.count)).rounded(.toNearestOrAwayFromZero))
    }
}

extension ScoreBand {
    /** The band above this one, nil for healthy. */
    package var next: ScoreBand? {
        switch self {
        case .vulnerable: .coping
        case .coping: .healthy
        case .healthy: nil
        }
    }

    /** The lowest score of the band: 0, 40 or 80. */
    package var lowerBound: Int {
        switch self {
        case .vulnerable: 0
        case .coping: 40
        case .healthy: 80
        }
    }

    /** Points `score` still needs to reach the next band, nil in the top band. */
    package func pointsToNext(from score: Int) -> Int? {
        guard let next else { return nil }
        return max(next.lowerBound - score, 0)
    }
}
