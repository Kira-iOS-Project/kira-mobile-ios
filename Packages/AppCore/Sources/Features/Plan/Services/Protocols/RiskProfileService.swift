import Domain

/**
 The calls behind Kenali Profil Risikomu (REN-06) and Hasil Kuis (REN-07). The server scores the
 answers with its deterministic table; the app never does. Every call throws an `AppProblem` when
 the API refuses it (`PUT` answers 422 VALIDATION_FAILED for answers out of range).
 */
package protocol RiskProfileService: Sendable {
    /** `GET /risk-profile` (`getRiskProfile`): the saved profile with its answers, nil before the first quiz. */
    func savedProfile() async throws -> SavedRiskProfile?
    /** `PUT /risk-profile` (`saveRiskProfile`): stores the five 0-based answers and returns the profile. */
    func saveRiskProfile(answers: [Int]) async throws -> RiskProfile
}

/**
 The quiz's numbers from the plan (`GET /plan`: the ladder's emergency-fund multiples and the
 prefill's income). The app composes it from `GoalService.plan()` when the plan's client lands;
 a failure never blocks the quiz, which then reads `RiskQuizContext.unknown`.
 */
package typealias RiskContextProvider = @Sendable () async throws -> RiskQuizContext
