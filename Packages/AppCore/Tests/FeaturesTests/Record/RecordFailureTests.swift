import APIClient
import Testing

@testable import Features

@Suite("RecordFailure")
struct RecordFailureTests {
    @Test("a problem the API answered with, or the connection")
    func kinds() {
        let problem = AppProblem(code: "VALIDATION_FAILED")
        #expect(RecordFailure(problem) == .problem(problem))
        #expect(RecordFailure(OfflineError()) == .connection)
    }
}
