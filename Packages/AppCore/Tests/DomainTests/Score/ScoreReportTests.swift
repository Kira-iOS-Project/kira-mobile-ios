/** ScoreReport holds the engine's report and finds a sub-score by its group. */
import Foundation
import Testing

@testable import Domain

@Suite("ScoreReport")
struct ScoreReportTests {
    @Test("starts with nothing listed, and finds a group it holds")
    func report() {
        let day = Date(timeIntervalSince1970: 0)
        var report = ScoreReport(score: 62, band: .coping, computedAt: day, nextCheckOn: day)
        #expect(report.delta == nil)
        #expect(report.groups.isEmpty && report.indicators.isEmpty && report.steps.isEmpty)
        #expect(!report.cappedByConsumerDebt)
        #expect(report.computedAt == day && report.nextCheckOn == day)
        report.groups = [GroupScore(group: .debt, points: 67, band: .coping)]
        #expect(report.group(.debt)?.points == 67)
        #expect(report.group(.debt)?.band == .coping)
        #expect(report.group(.save) == nil)
    }

    @Test("an indicator and a step keep what they are given; raw values are the backend's")
    func parts() {
        let measure = IndicatorMeasure.protectionCover(health: true, income: false)
        let indicator = ScoreIndicator(key: .protection, group: .protect, points: 50, band: .coping, measure: measure)
        #expect(indicator.key == .protection && indicator.group == .protect && indicator.points == 50)
        #expect(indicator.band == .coping && indicator.measure == measure)
        var step = ScoreStep(kind: .payOffDebt, estimatedGain: 5)
        step.debtName = "Paylater A"
        #expect(step.kind == .payOffDebt && step.estimatedGain == 5 && step.debtName == "Paylater A")
        #expect(step.shortfall == 0)
        step.currentAmount = 3_360_000
        step.targetAmount = 4_200_000
        #expect(step.shortfall == 840_000)
        step.currentAmount = 5_000_000
        #expect(step.shortfall == 0)
        #expect(IndicatorGroup.allCases.map(\.rawValue) == ["save_group", "debt_group", "protect_group"])
        #expect(ScoreStepKind.seekRelief.rawValue == "seek_relief")
    }
}
