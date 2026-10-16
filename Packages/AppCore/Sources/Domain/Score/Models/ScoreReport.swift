import Foundation

/**
 A Kira Score as the engine reports it (`GET /score`, and the answer to `PUT /health-check`): the
 score and band, the three sub-scores, the six indicators and at most three priority steps.
 */
package struct ScoreReport: Hashable, Sendable {
    /** The score, 0–100. */
    package let score: Int
    /** The band; capped at vulnerable when consumer debt scores 0. */
    package let band: ScoreBand
    /** The change since the previous payday period, nil when there is none. */
    package var delta: Int?
    /** When the engine computed it. */
    package var computedAt: Date
    /** The day the score is checked again (the next payday). */
    package var nextCheckOn: Date
    /** Tabung, Utang and Lindungi. */
    package var groups: [GroupScore]
    /** The six indicators, in the engine's order. */
    package var indicators: [ScoreIndicator]
    /** At most three priority steps, in order. */
    package var steps: [ScoreStep]
    /** Whether the band was capped by consumer debt. */
    package var cappedByConsumerDebt: Bool

    /** A report of `score` in `band`; the rest starts empty and is set as needed. */
    package init(score: Int, band: ScoreBand, computedAt: Date, nextCheckOn: Date) {
        self.score = score
        self.band = band
        self.computedAt = computedAt
        self.nextCheckOn = nextCheckOn
        groups = []
        indicators = []
        steps = []
        cappedByConsumerDebt = false
    }

    /** The sub-score of `group`, if the report has it. */
    package func group(_ group: IndicatorGroup) -> GroupScore? {
        groups.first { $0.group == group }
    }
}
