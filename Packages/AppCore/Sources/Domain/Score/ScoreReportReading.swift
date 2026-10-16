/**
 How the Kira Score screen (SKR-01) reads a report: indicators and groups in the screen's order,
 and the sentence under the meter.
 */
extension ScoreReport {
    /** The indicators in the order the screen lists them (`IndicatorKey.allCases`). */
    package var orderedIndicators: [ScoreIndicator] {
        IndicatorKey.allCases.compactMap { key in indicators.first { $0.key == key } }
    }

    /** The indicators of one group, in order. */
    package func indicators(in group: IndicatorGroup) -> [ScoreIndicator] {
        orderedIndicators.filter { $0.group == group }
    }

    /** The groups in the order of `IndicatorGroup.allCases`. */
    package var orderedGroups: [GroupScore] {
        IndicatorGroup.allCases.compactMap { group($0) }
    }

    /** The sentence under the meter. */
    package var bandMessage: BandMessage {
        if cappedByConsumerDebt { return .capped }
        guard let next = band.next else { return .healthy }
        return .below(next: next, pointsNeeded: max(next.lowerBound - score, 0))
    }
}

/** The sentence under the meter: how far the next band is, or why the band is capped. */
package enum BandMessage: Equatable, Sendable {
    case below(next: ScoreBand, pointsNeeded: Int)
    case healthy
    case capped
}

extension ScoreFormula {
    /** Whether the average is already whole, so "→ dibulatkan" is left out. */
    package var isWhole: Bool { average == Double(rounded) }
}
