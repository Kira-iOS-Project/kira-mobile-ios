import APIClient
import Domain

/** Riwayat Kira Score in the Domain's values: each `YYYY-MM` month as its first day. */
extension ScoreHistory {
    /** The history the API sent; a month it cannot read fails the load as the generic problem. */
    init(_ dto: ScoreHistoryDTO) throws {
        self.init(
            score: dto.score, band: dto.band, deltaFromPrevious: dto.deltaFromPrevious,
            previousMonth: try dto.previousMonth.map(Self.month),
            points: try dto.points.map { ScoreHistoryPoint(month: try Self.month($0.month), score: $0.score) },
            changes: dto.changes.map {
                IndicatorChange(
                    indicator: $0.indicator, fromLabel: $0.fromLabel, toLabel: $0.toLabel, fromPoints: $0.fromPoints,
                    toPoints: $0.toPoints)
            },
            unchangedCount: dto.unchangedCount)
    }

    /** `YYYY-MM` as the month's first day. */
    private static func month(_ text: String) throws -> CalendarDay {
        try Bridge.day(text + "-01")
    }
}
