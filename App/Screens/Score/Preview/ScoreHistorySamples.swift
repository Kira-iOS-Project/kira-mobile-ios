/**
 The boards' Riwayat Kira Score (RiwayatSkor, RiwayatSkorTahun): 66, Bertahan, four points up from
 September, Dana Darurat the one indicator that changed. Six or twelve monthly snapshots.
 */
import Domain
import Features

nonisolated extension ScoreHistory {
    /** The boards' scores, November 2025 to October 2026. */
    private static let yearScores = [40, 42, 44, 46, 47, 49, 51, 55, 58, 60, 62, 66]

    /** The board of `range`. */
    static func sample(_ range: ScoreHistoryRange) -> ScoreHistory {
        let first = CalendarDay(year: 2025, month: 11, day: 1)
        let year = yearScores.enumerated().map { index, score in
            ScoreHistoryPoint(month: first.adding(months: index), score: score)
        }
        return ScoreHistory(
            score: 66, band: .coping, deltaFromPrevious: 4, previousMonth: CalendarDay(year: 2026, month: 9, day: 1),
            points: range == .oneYear ? year : Array(year.suffix(6)),
            changes: [
                IndicatorChange(
                    indicator: .emergencyFund, fromLabel: "0,8×", toLabel: "1,1×", fromPoints: 25,
                    toPoints: 50)
            ],
            unchangedCount: 5)
    }
}
