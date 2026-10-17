import Foundation

/** The profile `GET /risk-profile` holds, with the answers it was computed from. */
package struct SavedRiskProfile: Hashable, Sendable {
    /** The profile. */
    package let profile: RiskProfile
    /** The five answers, which Ulangi Kuis fills in again. */
    package let answers: RiskAnswers

    /** A saved profile. */
    package init(profile: RiskProfile, answers: RiskAnswers) {
        self.profile = profile
        self.answers = answers
    }
}
