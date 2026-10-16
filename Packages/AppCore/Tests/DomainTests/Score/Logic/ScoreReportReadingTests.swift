import Foundation
import Testing

@testable import Domain

@Suite("ScoreReport reading")
struct ScoreReportReadingTests {
    private static let points: [IndicatorKey: Int] = [
        .emergencyFund: 50, .savingsRatio: 45, .instalmentRatio: 70, .consumerDebt: 50, .debtToAsset: 80,
        .protection: 100,
    ]

    private func indicator(_ key: IndicatorKey, _ group: IndicatorGroup) -> ScoreIndicator {
        let points = Self.points[key] ?? 0
        return ScoreIndicator(
            key: key, group: group, points: points, band: ScoreBand(score: points),
            measure: .protectionCover(health: true, income: true))
    }

    private func report(score: Int = 66, band: ScoreBand = .coping, capped: Bool = false) -> ScoreReport {
        var report = ScoreReport(
            score: score, band: band, computedAt: wibDay(2026, 10, 1), nextCheckOn: wibDay(2026, 10, 25))
        report.groups = [
            GroupScore(group: .protect, points: 100, band: .healthy),
            GroupScore(group: .save, points: 48, band: .coping),
            GroupScore(group: .debt, points: 67, band: .coping),
        ]
        report.indicators = [
            indicator(.protection, .protect), indicator(.debtToAsset, .debt), indicator(.consumerDebt, .debt),
            indicator(.instalmentRatio, .debt), indicator(.savingsRatio, .save), indicator(.emergencyFund, .save),
        ]
        report.cappedByConsumerDebt = capped
        return report
    }

    @Test("orders indicators and groups as the screen lists them, whatever the API's order")
    func order() {
        let report = report()
        #expect(report.orderedIndicators.map(\.key) == IndicatorKey.allCases)
        #expect(report.orderedGroups.map(\.group) == [.save, .debt, .protect])
        #expect(report.indicators(in: .debt).map(\.key) == [.instalmentRatio, .consumerDebt, .debtToAsset])
    }

    @Test("says how far the next band is, that Sehat is reached, or that the band is capped")
    func bandMessage() {
        #expect(report().bandMessage == .below(next: .healthy, pointsNeeded: 14))
        #expect(report(score: 28, band: .vulnerable).bandMessage == .below(next: .coping, pointsNeeded: 12))
        #expect(report(score: 85, band: .healthy).bandMessage == .healthy)
        #expect(report(score: 70, band: .vulnerable, capped: true).bandMessage == .capped)
    }

    @Test("leaves out the rounding step when the average is whole")
    func whole() {
        var even = ScoreReport(score: 60, band: .coping, computedAt: .distantPast, nextCheckOn: .distantPast)
        even.indicators = [indicator(.protection, .protect), indicator(.emergencyFund, .save)]
        #expect(ScoreFormula(even).isWhole)
        #expect(!ScoreFormula(report()).isWhole)
    }
}
