/**
 Riwayat Kira Score (SKR-07, SKR-07b): the score now, one snapshot per month (taken on the 25th,
 plus one at the first health check), and what changed since the month before. The server sends
 numbers and the indicators' own labels; every sentence around them is written on the device.
 */
package struct ScoreHistory: Hashable, Sendable {
    /** The score now. */
    package let score: Int
    /** Its band. */
    package let band: ScoreBand
    /** Points since the month before, or nil when there is none yet. */
    package let deltaFromPrevious: Int?
    /** The month before, as its first day, or nil when there is none yet. */
    package let previousMonth: CalendarDay?
    /** One snapshot per month, oldest first. */
    package let points: [ScoreHistoryPoint]
    /** The indicators that changed this month. */
    package let changes: [IndicatorChange]
    /** How many indicators stayed the same. */
    package let unchangedCount: Int

    /** A history as the API sends it. */
    package init(
        score: Int, band: ScoreBand, deltaFromPrevious: Int?, previousMonth: CalendarDay?,
        points: [ScoreHistoryPoint], changes: [IndicatorChange], unchangedCount: Int
    ) {
        self.score = score
        self.band = band
        self.deltaFromPrevious = deltaFromPrevious
        self.previousMonth = previousMonth
        self.points = points
        self.changes = changes
        self.unchangedCount = unchangedCount
    }
}

/** The score of one month. */
package struct ScoreHistoryPoint: Hashable, Sendable {
    /** The month, as its first day. */
    package let month: CalendarDay
    /** The score that month. */
    package let score: Int

    /** `score` in `month`. */
    package init(month: CalendarDay, score: Int) {
        self.month = month
        self.score = score
    }
}

/** One indicator that changed this month: its labels and points before and now. */
package struct IndicatorChange: Hashable, Sendable {
    /** Which indicator. */
    package let indicator: IndicatorKey
    /** The figure last month ("0,8×"), or nil when that month's figures were not kept. */
    package let fromLabel: String?
    /** The figure now ("1,1×"); the app adds the words around it. */
    package let toLabel: String
    /** Its points last month. */
    package let fromPoints: Int
    /** Its points now. */
    package let toPoints: Int

    /** A change as the API sends it. */
    package init(indicator: IndicatorKey, fromLabel: String?, toLabel: String, fromPoints: Int, toPoints: Int) {
        self.indicator = indicator
        self.fromLabel = fromLabel
        self.toLabel = toLabel
        self.fromPoints = fromPoints
        self.toPoints = toPoints
    }

    /** Points gained, negative when lost. */
    package var gain: Int { toPoints - fromPoints }
}

/** The span Riwayat Kira Score shows: 6 Bulan or 1 Tahun. */
package enum ScoreHistoryRange: String, CaseIterable, Sendable {
    /** The last six months (SKR-07). */
    case sixMonths = "6m"
    /** The last twelve months (SKR-07b). */
    case oneYear = "1y"
}
