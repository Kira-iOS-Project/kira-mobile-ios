import Domain
import Testing

@testable import Features

@MainActor
@Suite("HealthCheckResultModel")
struct HealthCheckResultModelTests {
    @Test("groups in the board's order, three numbered steps, the formula and the points to Sehat")
    func content() {
        var continued = false
        let model = HealthCheckResultModel(report: FakeOnboardingService.report) { continued = true }
        #expect(model.groups.map(\.group) == [.save, .protect])
        #expect(model.steps.map(\.number) == [1, 2, 3])
        #expect(model.steps.map(\.step.estimatedGain) == [1, 2, 3])
        #expect(model.formula.points.isEmpty)
        #expect(model.pointsToNextBand == 18)
        #expect(!model.isFormulaOpen)
        model.continueToLock()
        #expect(continued)
    }

    @Test("a band capped by consumer debt names no points to the next")
    func capped() {
        var report = FakeOnboardingService.report
        report.cappedByConsumerDebt = true
        #expect(HealthCheckResultModel(report: report) {}.pointsToNextBand == nil)
    }
}
