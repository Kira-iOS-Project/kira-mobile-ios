import Domain
import Testing

@Suite("ScoreHistoryTrend")
struct ScoreHistoryTrendTests {
    private func points(_ scores: [Int], from first: CalendarDay = CalendarDay(year: 2026, month: 5, day: 1))
        -> [ScoreHistoryPoint]
    {
        scores.enumerated().map { ScoreHistoryPoint(month: first.adding(months: $0), score: $1) }
    }

    @Test("the board's six months: up 15 since May, within one year")
    func up() throws {
        let trend = try #require(ScoreHistoryTrend(points([51, 55, 58, 60, 62, 66])))
        #expect(trend.direction == .rising && trend.points == 15 && trend.start == 51 && trend.end == 66)
        #expect(trend.since == CalendarDay(year: 2026, month: 5, day: 1) && !trend.crossesYear)
    }

    @Test("a year from November 2025 crosses into 2026")
    func year() throws {
        let scores = [40, 42, 44, 46, 47, 49, 51, 55, 58, 60, 62, 66]
        let trend = try #require(ScoreHistoryTrend(points(scores, from: CalendarDay(year: 2025, month: 11, day: 1))))
        #expect(trend.crossesYear && trend.points == 26 && trend.until == CalendarDay(year: 2026, month: 10, day: 1))
    }

    @Test("down and flat, and no trend with fewer than two months")
    func others() throws {
        let down = try #require(ScoreHistoryTrend(points([60, 52])))
        #expect(down.direction == .falling && down.points == 8)
        #expect(try #require(ScoreHistoryTrend(points([60, 60]))).direction == .steady)
        #expect(ScoreHistoryTrend(points([66])) == nil && ScoreHistoryTrend([]) == nil)
    }

    @Test("a change's gain is its points now less then")
    func gain() {
        let change = IndicatorChange(
            indicator: .emergencyFund, fromLabel: nil, toLabel: "1,1×", fromPoints: 50, toPoints: 25)
        #expect(change.gain == -25)
        #expect(ScoreHistoryRange.allCases.map(\.rawValue) == ["6m", "1y"])
    }
}
