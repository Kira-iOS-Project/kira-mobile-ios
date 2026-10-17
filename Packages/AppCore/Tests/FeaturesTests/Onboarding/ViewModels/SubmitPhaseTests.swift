import APIClient
import Testing

@testable import Features

@Suite("SubmitPhase")
struct SubmitPhaseTests {
    private struct Plain: Error {}

    @Test("says whether it is sending and which problem to show")
    func members() {
        let problem = AppProblem(code: "INTERNAL_ERROR")
        #expect(SubmitPhase.submitting.isSubmitting)
        #expect(!SubmitPhase.editing.isSubmitting)
        #expect(SubmitPhase.failed(problem).problem == problem)
        #expect(SubmitPhase.editing.problem == nil)
    }

    @Test("an AppProblem stays itself; any other error becomes a problem without a code")
    func failure() {
        let problem = AppProblem(code: "INTERNAL_ERROR")
        #expect(SubmitPhase.failure(problem) == .failed(problem))
        #expect(SubmitPhase.failure(Plain()) == .failed(AppProblem()))
    }
}
