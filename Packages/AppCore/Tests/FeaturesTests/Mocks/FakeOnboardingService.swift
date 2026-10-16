import APIClient
import Domain
import Foundation

@testable import Features

/**
 The API boundary of onboarding, replaced for the tests: it records each call and answers with
 what the test set, failing the first `failures` calls with `problem`.
 */
actor FakeOnboardingService: OnboardingService {
    /** A call the screens made, with what they sent. */
    enum Call: Equatable {
        case requestCode(String)
        case verify(String, String)
        case consents(ConsentChoices)
        case focus(Focus)
        case hideBalances(Bool)
        case healthCheck(HealthCheckAnswers)
    }

    static let problem = AppProblem(code: "AUTH_CODE_INVALID", requestId: "req-1")
    static let report: ScoreReport = {
        var report = ScoreReport(score: 62, band: .coping, computedAt: .distantPast, nextCheckOn: .distantFuture)
        report.groups = [
            GroupScore(group: .protect, points: 100, band: .healthy),
            GroupScore(group: .save, points: 35, band: .vulnerable),
        ]
        report.steps = (1...4).map { ScoreStep(kind: .raiseSavings, estimatedGain: $0) }
        return report
    }()

    private(set) var calls: [Call] = []
    private var failures: Int
    private let needsOnboarding: Bool
    private let resendAfter: Int

    init(failures: Int = 0, needsOnboarding: Bool = true, resendAfter: Int = 60) {
        self.failures = failures
        self.needsOnboarding = needsOnboarding
        self.resendAfter = resendAfter
    }

    func requestCode(email: String) throws -> CodeDelivery {
        try record(.requestCode(email))
        return CodeDelivery(resendAfterSeconds: resendAfter)
    }

    func verify(email: String, code: String) throws -> SignInResult {
        try record(.verify(email, code))
        return SignInResult(needsOnboarding: needsOnboarding)
    }

    func saveConsents(_ choices: ConsentChoices) throws { try record(.consents(choices)) }

    func saveFocus(_ focus: Focus) throws { try record(.focus(focus)) }

    func saveHideBalances(_ isHidden: Bool) throws { try record(.hideBalances(isHidden)) }

    func submitHealthCheck(_ answers: HealthCheckAnswers) throws -> ScoreReport {
        try record(.healthCheck(answers))
        return Self.report
    }

    private func record(_ call: Call) throws {
        calls.append(call)
        if failures > 0 {
            failures -= 1
            throw Self.problem
        }
    }
}

/** The Keychain boundary of the PIN, replaced: it keeps what it is given, or fails once. */
actor FakePinSetup: PinSetup {
    /** What the Keychain was never meant to see: a plain error, not an AppProblem. */
    struct Failure: Error {}

    private(set) var saved: [String] = []
    private var fails: Bool

    init(fails: Bool = false) {
        self.fails = fails
    }

    func save(pin: String) throws {
        if fails {
            fails = false
            throw Failure()
        }
        saved.append(pin)
    }
}
