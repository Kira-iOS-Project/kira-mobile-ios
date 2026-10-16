/**
 Onboarding's service before the integrator connects the API: it answers with the canvas's
 sample data (Dinda's first Kira Score of 62, Bertahan), after a short pause, so the screens run in
 previews and in the app. Every code works and every account is new.
 */
import Domain
import Features
import Foundation

struct PreviewOnboardingService: OnboardingService {
    func requestCode(email _: String) async throws -> CodeDelivery {
        try await pause()
        return CodeDelivery(resendAfterSeconds: 60)
    }

    func verify(email _: String, code _: String) async throws -> SignInResult {
        try await pause()
        return SignInResult(needsOnboarding: true)
    }

    func saveConsents(_: ConsentChoices) async throws { try await pause() }

    func saveFocus(_: Focus) async throws { try await pause() }

    func saveHideBalances(_: Bool) async throws { try await pause() }

    func submitHealthCheck(_: HealthCheckAnswers) async throws -> ScoreReport {
        try await pause()
        return Self.sampleReport
    }

    private func pause() async throws {
        try await Task.sleep(for: .milliseconds(400))
    }

    /** HasilCekAwal: 62, Bertahan; Tabung 35, Utang 67, Lindungi 100; three steps. */
    static let sampleReport: ScoreReport = {
        var report = ScoreReport(score: 62, band: .coping, computedAt: .now, nextCheckOn: .now)
        report.groups = [
            GroupScore(group: .save, points: 35, band: .vulnerable),
            GroupScore(group: .debt, points: 67, band: .coping),
            GroupScore(group: .protect, points: 100, band: .healthy),
        ]
        report.indicators = sampleIndicators
        report.steps = sampleSteps
        return report
    }()

    private static let sampleIndicators: [ScoreIndicator] = [
        ScoreIndicator(
            key: .emergencyFund, group: .save, points: 25, band: .vulnerable,
            measure: .emergencyFund(
                ratio: 0.8, liquid: 3_360_000, essential: 4_200_000, targetMultiple: 6, targetAmount: 25_200_000)),
        ScoreIndicator(
            key: .savingsRatio, group: .save, points: 45, band: .coping,
            measure: .savingsRatio(percent: 8, monthlySavings: 600_000, income: 7_500_000)),
        ScoreIndicator(
            key: .instalmentRatio, group: .debt, points: 70, band: .coping,
            measure: .instalmentRatio(percent: 18, monthlyInstalments: 1_350_000, income: 7_500_000)),
        ScoreIndicator(
            key: .consumerDebt, group: .debt, points: 50, band: .coping,
            measure: .consumerDebt(platforms: 2, anyLate: false, anyOverdue: false)),
        ScoreIndicator(
            key: .debtToAsset, group: .debt, points: 80, band: .healthy,
            measure: .debtToAsset(percent: 34, totalDebt: 14_310_000, totalAssets: 42_000_000)),
        ScoreIndicator(
            key: .protection, group: .protect, points: 100, band: .healthy,
            measure: .protectionCover(health: true, income: true)),
    ]

    private static var sampleSteps: [ScoreStep] {
        var payOff = ScoreStep(kind: .payOffDebt, estimatedGain: 5)
        payOff.debtName = "Paylater A"
        payOff.remaining = 420_000
        var fund = ScoreStep(kind: .buildEmergencyFund, estimatedGain: 4)
        fund.targetMultiple = 1
        fund.currentAmount = 3_360_000
        fund.targetAmount = 4_200_000
        var savings = ScoreStep(kind: .raiseSavings, estimatedGain: 4)
        savings.targetPercent = 10
        savings.currentAmount = 600_000
        savings.targetAmount = 750_000
        return [payOff, fund, savings]
    }
}

/** The PIN store before agent I0's Keychain one: it keeps nothing. */
struct PreviewPinSetup: PinSetup {
    func save(pin _: String) throws {}
}
