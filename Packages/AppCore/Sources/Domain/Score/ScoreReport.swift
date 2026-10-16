import Foundation

/** The Kira Score with its groups, six indicators and steps: `GET /score`. */
package struct ScoreReport: Equatable, Sendable {
    package let score: Score
    /** The band the engine sent, which a red flag can cap below the score's own band. */
    package let band: ScoreBand
    package let delta: Int?
    package let isInitial: Bool
    package let computedAt: Date
    package let nextCheckOn: Date
    package let groups: [GroupScore]
    package let indicators: [Indicator]
    package let steps: [ScoreStep]
    package let cappedByConsumerDebt: Bool

    package init(
        score: Score, band: ScoreBand, delta: Int?, isInitial: Bool, computedAt: Date, nextCheckOn: Date,
        groups: [GroupScore], indicators: [Indicator], steps: [ScoreStep], cappedByConsumerDebt: Bool
    ) {
        self.score = score
        self.band = band
        self.delta = delta
        self.isInitial = isInitial
        self.computedAt = computedAt
        self.nextCheckOn = nextCheckOn
        self.groups = groups
        self.indicators = indicators
        self.steps = steps
        self.cappedByConsumerDebt = cappedByConsumerDebt
    }

    /** The indicators in the order the screen lists them (`IndicatorKey.allCases`). */
    package var orderedIndicators: [Indicator] {
        IndicatorKey.allCases.compactMap { key in indicators.first { $0.key == key } }
    }

    /** The indicators of one group, in order. */
    package func indicators(in group: IndicatorGroup) -> [Indicator] {
        orderedIndicators.filter { $0.group == group }
    }

    /** The groups in the order of `IndicatorGroup.allCases`. */
    package var orderedGroups: [GroupScore] {
        IndicatorGroup.allCases.compactMap { group in groups.first { $0.group == group } }
    }

    /** The sum and the average of the six indicators, as the formula writes them. */
    package var formula: ScoreFormula { ScoreFormula(points: orderedIndicators.map(\.points.value)) }

    /** The sentence under the meter. */
    package var bandMessage: BandMessage {
        if cappedByConsumerDebt { return .capped }
        switch band {
        case .vulnerable: return .below(next: .coping, pointsNeeded: max(40 - score.value, 0))
        case .coping: return .below(next: .healthy, pointsNeeded: max(80 - score.value, 0))
        case .healthy: return .healthy
        }
    }
}

/** The sentence under the meter: how far the next band is, or why the band is capped. */
package enum BandMessage: Equatable, Sendable {
    case below(next: ScoreBand, pointsNeeded: Int)
    case healthy
    case capped
}

/** The three groups the indicators fall in: Tabung, Utang and Lindungi on screen. */
package enum IndicatorGroup: String, CaseIterable, Sendable {
    case save = "save_group"
    case debt = "debt_group"
    case protect = "protect_group"
}

/** One group's points and band. */
package struct GroupScore: Equatable, Sendable {
    package let group: IndicatorGroup
    package let points: Score
    package let band: ScoreBand

    package init(group: IndicatorGroup, points: Score, band: ScoreBand) {
        self.group = group
        self.points = points
        self.band = band
    }
}

/**
 The equal-weight average written out: "(50 + 45 + 70 + 50 + 80 + 100) ÷ 6", then "= 65,8 →
 dibulatkan 66", or "= 66" when the average is whole.
 */
package struct ScoreFormula: Equatable, Sendable {
    package let points: [Int]

    package init(points: [Int]) {
        self.points = points
    }

    /** The average to one decimal, rounded half up. */
    package var average: Decimal {
        guard !points.isEmpty else { return 0 }
        return Decimal(points.reduce(0, +)).rounded(1, dividedBy: Decimal(points.count))
    }

    /** The average rounded half up to a whole score. */
    package var rounded: Int {
        NSDecimalNumber(decimal: average.rounded(0, dividedBy: 1)).intValue
    }

    /** Whether the average is already whole, so the rounding step is left out. */
    package var isWhole: Bool { average == Decimal(rounded) }
}

extension Decimal {
    /** `self ÷ divisor`, rounded half up to `scale` decimals; zero when the divisor is zero. */
    package func rounded(_ scale: Int, dividedBy divisor: Decimal) -> Decimal {
        guard divisor != 0 else { return 0 }
        var quotient = self / divisor
        var result = Decimal()
        NSDecimalRound(&result, &quotient, scale, .plain)
        return result
    }
}
