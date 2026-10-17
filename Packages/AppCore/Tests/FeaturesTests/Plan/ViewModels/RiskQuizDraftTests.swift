import Domain
import Testing

@testable import Features

@MainActor
@Suite("RiskQuizDraft")
struct RiskQuizDraftTests {
    @Test("clearing forgets every answer, so the next person starts the quiz empty")
    func clears() {
        let draft = RiskQuizDraft(answers: RiskAnswers([1, 1, 1, 0, 1]))
        draft.clear()
        #expect(draft.answers == RiskAnswers())
    }
}
