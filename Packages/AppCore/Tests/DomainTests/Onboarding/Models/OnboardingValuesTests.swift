/** The small onboarding values spell the backend's words and keep what they are given. */
import Testing

@testable import Domain

@Suite("Onboarding values")
struct OnboardingValuesTests {
    @Test("focus, marital status and protection use the backend's raw values")
    func rawValues() {
        #expect(Focus.allCases.map(\.rawValue) == ["track_spending", "debt_free"])
        #expect(MaritalStatus.allCases.map(\.rawValue) == ["single", "married"])
        #expect(
            Protection.allCases.map(\.rawValue) == [
                "bpjs_health", "bpjs_employment", "life_insurance", "private_health",
            ])
    }

    @Test("consents start on; a delivery and a sign-in result keep their fields")
    func values() {
        #expect(ConsentChoices() == ConsentChoices(aiProcessing: true, weeklySummary: true))
        #expect(CodeDelivery(resendAfterSeconds: 60).resendAfterSeconds == 60)
        #expect(SignInResult(needsOnboarding: true).needsOnboarding)
    }

    @Test("empty answers: pay on the 25th, nothing else filled")
    func emptyAnswers() {
        let answers = HealthCheckAnswers()
        #expect(answers.payday == Payday(day: 25))
        #expect(answers.netMonthlyIncome == nil)
        #expect(answers.debts.isEmpty)
        #expect(answers.dependents == 0)
        #expect(answers.maritalStatus == nil)
        #expect(answers.protections.isEmpty)
    }
}
