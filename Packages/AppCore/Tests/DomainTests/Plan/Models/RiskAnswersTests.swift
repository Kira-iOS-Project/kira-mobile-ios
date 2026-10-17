import Testing

@testable import Domain

@Suite("RiskAnswers")
struct RiskAnswersTests {
    @Test("the board's persona is [1, 1, 1, 0, 1]; an answer out of range is ignored")
    func persona() {
        var answers = RiskAnswers()
        #expect(answers.indexes == nil && answers.choice(for: .goal) == nil)
        for (question, option) in zip(RiskQuestion.allCases, [1, 1, 1, 0, 1]) {
            answers.choose(option, for: question)
        }
        answers.choose(4, for: .goal)
        answers.choose(-1, for: .goal)
        #expect(answers.indexes == [1, 1, 1, 0, 1])
        #expect(answers == RiskAnswers([1, 1, 1, 0, 1]))
        #expect(RiskAnswers([2, 3]).choice(for: .drawdown) == 3 && RiskAnswers([2, 3]).indexes == nil)
    }

    @Test("five questions of four options, numbered from 1, each with its neighbours")
    func questions() {
        #expect(RiskQuestion.total == 5 && RiskQuestion.optionCount == 4)
        #expect(RiskQuestion.allCases.map(\.number) == [1, 2, 3, 4, 5])
        #expect(RiskQuestion.goal.previous == nil && RiskQuestion.goal.next == .drawdown)
        #expect(RiskQuestion.monthlyDeposit.next == nil && RiskQuestion.monthlyDeposit.previous == .experience)
    }

    @Test("a saved profile holds its answers")
    func saved() {
        let saved = SavedRiskProfile(profile: .moderate, answers: RiskAnswers([1, 1, 1, 0, 1]))
        #expect(saved.profile == .moderate && saved.answers.indexes == [1, 1, 1, 0, 1])
        #expect(RiskProfile.allCases.map(\.rawValue) == ["conservative", "moderate", "aggressive"])
    }
}
