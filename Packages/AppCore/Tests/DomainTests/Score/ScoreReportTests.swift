import Foundation
import Testing

@testable import Domain

@Suite("ScoreReport")
struct ScoreReportTests {
    private static let points: [IndicatorKey: Int] = [
        .emergencyFund: 50, .savingsRatio: 45, .instalmentRatio: 70, .consumerDebt: 50, .debtToAsset: 80,
        .protection: 100,
    ]

    private func indicator(_ key: IndicatorKey, _ group: IndicatorGroup) -> Indicator {
        let points = Score(Self.points[key] ?? 0)
        return Indicator(
            key: key, group: group, points: points, band: points.band,
            measure: .protection(ProtectionMeasure(health: true, income: true)))
    }

    private func report(score: Int = 66, band: ScoreBand = .coping, capped: Bool = false) -> ScoreReport {
        ScoreReport(
            score: Score(score), band: band, delta: 4, isInitial: false, computedAt: wibDay(2026, 10, 1),
            nextCheckOn: wibDay(2026, 10, 25),
            groups: [
                GroupScore(group: .protect, points: Score(100), band: .healthy),
                GroupScore(group: .save, points: Score(48), band: .coping),
                GroupScore(group: .debt, points: Score(67), band: .coping),
            ],
            indicators: [
                indicator(.protection, .protect), indicator(.debtToAsset, .debt), indicator(.consumerDebt, .debt),
                indicator(.instalmentRatio, .debt), indicator(.savingsRatio, .save), indicator(.emergencyFund, .save),
            ],
            steps: [], cappedByConsumerDebt: capped)
    }

    @Test("orders indicators and groups as the screen lists them, whatever the API's order")
    func order() {
        let report = report()
        #expect(report.orderedIndicators.map(\.key) == IndicatorKey.allCases)
        #expect(report.orderedGroups.map(\.group) == [.save, .debt, .protect])
        #expect(report.indicators(in: .debt).map(\.key) == [.instalmentRatio, .consumerDebt, .debtToAsset])
        #expect(report.orderedGroups.first?.points == Score(48))
    }

    @Test("writes the average to one decimal, then rounds it half up")
    func formula() {
        let formula = report().formula
        #expect(formula.points == [50, 45, 70, 50, 80, 100])
        #expect(formula.average == Decimal(string: "65.8"))
        #expect(formula.rounded == 66)
        #expect(!formula.isWhole)
        #expect(ScoreFormula(points: [60, 60]).isWhole)
        #expect(ScoreFormula(points: [1, 2]).rounded == 2)
        #expect(ScoreFormula(points: []).average == 0)
    }

    @Test("says how far the next band is, that Sehat is reached, or that the band is capped")
    func bandMessage() {
        #expect(report().bandMessage == .below(next: .healthy, pointsNeeded: 14))
        #expect(report(score: 28, band: .vulnerable).bandMessage == .below(next: .coping, pointsNeeded: 12))
        #expect(report(score: 85, band: .healthy).bandMessage == .healthy)
        #expect(report(score: 70, band: .vulnerable, capped: true).bandMessage == .capped)
        #expect(report(score: 45, band: .vulnerable).bandMessage == .below(next: .coping, pointsNeeded: 0))
    }

    @Test("rounds a quotient half up, and a division by zero to zero")
    func rounding() {
        #expect(Decimal(4_800_000).rounded(2, dividedBy: 4_200_000) == Decimal(string: "1.14"))
        #expect(Decimal(5).rounded(0, dividedBy: 2) == 3)
        #expect(Decimal(5).rounded(2, dividedBy: 0) == 0)
    }

    @Test("works out a step's shortfall, never below zero")
    func shortfall() {
        let step = ScoreStep(
            kind: .buildEmergencyFund, estimatedGain: 4, currentAmount: 4_800_000, targetAmount: 12_600_000,
            targetMultiple: 3)
        #expect(step.shortfall == 7_800_000)
        #expect(ScoreStep(kind: .raiseSavings, estimatedGain: 1, currentAmount: 9, targetAmount: 5).shortfall == 0)
        #expect(ScoreStep(kind: .addProtection, estimatedGain: 1).shortfall == 0)
        #expect(ScoreStep(kind: .payOffDebt, estimatedGain: 5, debtName: "Paylater A", remaining: 420_000).debtName != nil)
        #expect(ScoreStep.Kind(rawValue: "seek_relief") == .seekRelief)
    }
}
