import Domain
import Foundation

/** The Kira Score as `GET /api/score` and `PUT /api/health-check` report it (SKR-01, ONB-13). */

/** The three groups of HasilCekAwal: Tabung, Utang, Lindungi. */
package enum IndicatorGroupDTO: String, CaseIterable, Sendable {
    /** Tabung: emergency fund and savings ratio. */
    case save = "save_group"
    /** Utang: instalments, consumer debt and debt to assets. */
    case debt = "debt_group"
    /** Lindungi: protection. */
    case protect = "protect_group"
}

/** One group's rounded average. */
package struct GroupScoreDTO: Hashable, Sendable {
    /** Which group. */
    package let group: IndicatorGroupDTO
    /** 0–100. */
    package let points: Int
    /** The group's band. */
    package let band: ScoreBand
}

/** One indicator's points and what it measured. */
package struct IndicatorDTO: Hashable, Sendable {
    /** Which indicator. */
    package let key: IndicatorKey
    /** Its group. */
    package let group: IndicatorGroupDTO
    /** 0–100. */
    package let points: Int
    /** The indicator's band. */
    package let band: ScoreBand
    /** The numbers the app writes the indicator's text from. */
    package let measure: IndicatorMeasureDTO

    init(_ indicator: Components.Schemas.Indicator) throws {
        key = try bridged(indicator.key)
        group = try bridged(indicator.group)
        points = indicator.points
        band = try bridged(indicator.band)
        measure = try IndicatorMeasureDTO(key: key, indicator.measure)
    }
}

/** The whole score report. */
package struct ScoreReportDTO: Hashable, Sendable {
    /** 0–100. */
    package let score: Int
    /** The band, capped at vulnerable while consumer debt scores 0. */
    package let band: ScoreBand
    /** Change since the last score before this payday period; nil when there is none. */
    package let delta: Int?
    /** When this period's score was taken. */
    package let computedAt: Date
    /** The next automatic check: the next payday (`YYYY-MM-DD`). */
    package let nextCheckOn: String
    /** Tabung, Utang, Lindungi. */
    package let groups: [GroupScoreDTO]
    /** The six indicators, in the engine's order. */
    package let indicators: [IndicatorDTO]
    /** Tiga Langkah Prioritas: at most three. */
    package let steps: [ScoreStepDTO]
    /** Consumer debt at 0 held the band at vulnerable. */
    package let cappedByConsumerDebt: Bool

    init(_ report: Components.Schemas.ScoreReport) throws {
        score = report.score
        band = try bridged(report.band)
        delta = report.delta
        computedAt = report.computedAt
        nextCheckOn = report.nextCheckOn
        groups = try report.groups.map {
            GroupScoreDTO(group: try bridged($0.group), points: $0.points, band: try bridged($0.band))
        }
        indicators = try report.indicators.map(IndicatorDTO.init)
        steps = try report.steps.map(ScoreStepDTO.init)
        cappedByConsumerDebt = report.cappedByConsumerDebt
    }
}
