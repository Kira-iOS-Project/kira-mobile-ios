import APIClient
import Domain
import Foundation

@testable import Features

/** The API boundary of the risk profile, answering from what a test sets. */
actor FakeRiskProfileService: RiskProfileService {
    static let problem = AppProblem(code: "VALIDATION_FAILED", requestId: "req-1")

    var saved: SavedRiskProfile?
    var profile = RiskProfile.moderate
    var readFailure: (any Error)?
    /** The saves that fail, first to last, before the next one goes through. */
    var saveFailures: [any Error] = []
    private(set) var sent: [[Int]] = []

    func configure(_ change: @Sendable (isolated FakeRiskProfileService) -> Void) { change(self) }

    func savedProfile() throws -> SavedRiskProfile? {
        if let readFailure { throw readFailure }
        return saved
    }

    func saveRiskProfile(answers: [Int]) throws -> RiskProfile {
        sent.append(answers)
        if !saveFailures.isEmpty { throw saveFailures.removeFirst() }
        return profile
    }
}
