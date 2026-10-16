/**
 The score's API answered with the canvas's sample data (board KiraScore and the six Detail
 Indikator boards), so the screens run in previews and in the app before integration.
 */
import Domain
import Features
import SwiftUI

nonisolated extension ScoreReport {
    /** Board KiraScore: 66, Bertahan, four points up, from the check of 1 October 2026. */
    static let sample: ScoreReport = {
        var report = ScoreReport(
            score: 66, band: .coping, computedAt: Date(timeIntervalSince1970: 1_790_787_600),
            nextCheckOn: Date(timeIntervalSince1970: 1_792_861_200))
        report.delta = 4
        report.isInitial = false
        report.groups = [
            GroupScore(group: .save, points: 48, band: .coping),
            GroupScore(group: .debt, points: 67, band: .coping),
            GroupScore(group: .protect, points: 100, band: .healthy),
        ]
        report.indicators = IndicatorKey.allCases.map(ScoreIndicator.sample)
        report.steps = [payOff, emergencyFund, savings]
        return report
    }()

    private static let payOff: ScoreStep = {
        var step = ScoreStep(kind: .payOffDebt, estimatedGain: 5)
        step.debtName = "Paylater A"
        step.remaining = 420_000
        return step
    }()

    private static let emergencyFund: ScoreStep = {
        var step = ScoreStep(kind: .buildEmergencyFund, estimatedGain: 4)
        step.currentAmount = 4_800_000
        step.targetAmount = 12_600_000
        step.targetMultiple = 3
        return step
    }()

    private static let savings: ScoreStep = {
        var step = ScoreStep(kind: .raiseSavings, estimatedGain: 4)
        step.currentAmount = 600_000
        step.targetAmount = 750_000
        step.targetPercent = 10
        return step
    }()
}

nonisolated struct PreviewScoreService: ScoreService {
    func score() throws -> ScoreReport? { .sample }

    func indicator(_ key: IndicatorKey) throws -> IndicatorDetail { .sample(key) }
}

#if DEBUG
    #Preview("Kira Score") {
        NavigationStack { ScoreScreen(service: PreviewScoreService()) { _ in } }
    }

    #Preview("Dana Darurat") {
        NavigationStack { IndicatorScreen(key: .emergencyFund, service: PreviewScoreService()) { _ in } }
    }

    #Preview("Utang terhadap Aset") {
        NavigationStack { IndicatorScreen(key: .debtToAsset, service: PreviewScoreService()) { _ in } }
    }
#endif
