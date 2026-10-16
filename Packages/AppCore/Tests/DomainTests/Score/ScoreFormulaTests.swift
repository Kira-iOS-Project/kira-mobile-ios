/** ScoreFormula shows the working of a score, and a band knows the points to the next (ONB-13). */
import Foundation
import Testing

@testable import Domain

@Suite("ScoreFormula")
struct ScoreFormulaTests {
    private func report(points: [Int]) -> ScoreReport {
        var report = ScoreReport(score: 0, band: .vulnerable, computedAt: .distantPast, nextCheckOn: .distantPast)
        report.indicators = points.enumerated().map { index, value in
            ScoreIndicator(
                key: IndicatorKey.allCases[index % 6], group: .save, points: value, band: .coping,
                measure: .consumerDebt(platforms: 0, anyLate: false, anyOverdue: false))
        }
        return report
    }

    @Test("the board's example: 370 ÷ 6 = 61,7, rounded 62")
    func boardExample() {
        let formula = ScoreFormula(report(points: [25, 45, 70, 50, 80, 100]))
        #expect(formula.points == [25, 45, 70, 50, 80, 100])
        #expect(formula.average == 61.7)
        #expect(formula.rounded == 62)
    }

    @Test("a half rounds up, and no indicators gives 0")
    func edges() {
        #expect(ScoreFormula(report(points: [61, 62])).rounded == 62)
        #expect(ScoreFormula(report(points: [])).average == 0)
        #expect(ScoreFormula(report(points: [])).rounded == 0)
    }

    @Test("each band names the next and the points still needed")
    func nextBand() {
        #expect(ScoreBand.coping.pointsToNext(from: 62) == 18)
        #expect(ScoreBand.vulnerable.pointsToNext(from: 25) == 15)
        #expect(ScoreBand.vulnerable.pointsToNext(from: 62) == 0)
        #expect(ScoreBand.healthy.pointsToNext(from: 90) == nil)
        #expect(ScoreBand.allCases.map(\.lowerBound) == [0, 40, 80])
        #expect(ScoreBand.allCases.map(\.next) == [.coping, .healthy, nil])
    }
}
