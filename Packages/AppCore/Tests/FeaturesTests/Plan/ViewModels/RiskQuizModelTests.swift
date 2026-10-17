import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("RiskQuizModel")
struct RiskQuizModelTests {
    private let service = FakeRiskProfileService()
    private let plans = FakeGoalService()
    private static let board = RiskQuizContext(emergencyMultiple: 1.1, emergencyTarget: 6, monthlyIncome: 7_500_000)
    private static let persona = [1, 1, 1, 0, 1]

    private func model(_ draft: RiskQuizDraft = RiskQuizDraft(), start: RiskQuizModel.Start = .quiz()) -> RiskQuizModel {
        RiskQuizModel(service: service, draft: draft, plans: plans, start: start)
    }

    /** The board's plan: the fund at 1,1× of 6×, Rp7.500.000,00 of income. */
    private func boardPlan() async {
        await plans.configure {
            $0.overview.ladder = [
                LadderStep(
                    step: 2, key: .emergencyFund, status: .todo,
                    detail: LadderDetail(multiple: 1.1, targetMultiple: 6))
            ]
            $0.overview.prefill.monthlyIncome = 7_500_000
        }
    }

    @Test("Lanjut waits for a choice; the board's persona sends [1, 1, 1, 0, 1] and shows Moderat")
    func persona() async {
        await boardPlan()
        let quiz = model()
        await quiz.load()
        #expect(quiz.phase.value == Self.board && !quiz.canContinue)
        await quiz.next()
        #expect(quiz.stage == .question(.goal))
        for option in Self.persona {
            quiz.choose(option)
            #expect(quiz.canContinue)
            await quiz.next()
        }
        #expect(await service.sent == [Self.persona])
        #expect(quiz.stage == .result(.moderate) && !quiz.canContinue && !quiz.isSaving)
        quiz.choose(2)
        quiz.back()
        #expect(quiz.stage == .result(.moderate))
        quiz.restart()
        #expect(quiz.stage == .question(.goal) && quiz.choice(for: .goal) == 1)
    }

    @Test("Kembali keeps each answer; on the first question it closes the quiz, and the draft outlives it")
    func back() async {
        let draft = RiskQuizDraft()
        let quiz = model(draft)
        quiz.choose(2)
        await quiz.next()
        quiz.choose(3)
        quiz.back()
        #expect(quiz.stage == .question(.goal) && quiz.choice(for: .goal) == 2 && !quiz.isClosed)
        quiz.back()
        #expect(quiz.isClosed)
        let again = model(draft, start: .quiz(.drawdown))
        #expect(again.choice(for: .drawdown) == 3 && again.stage == .question(.drawdown))
    }

    @Test("a failed save keeps the answers and shows its problem; Coba Lagi sends them again", arguments: [true, false])
    func failure(offline: Bool) async {
        let error: any Error = offline ? URLError(.notConnectedToInternet) : FakeRiskProfileService.problem
        await service.configure { $0.saveFailures = [error] }
        let quiz = model(RiskQuizDraft(answers: RiskAnswers(Self.persona)), start: .quiz(.monthlyDeposit))
        await quiz.next()
        #expect(quiz.stage == .question(.monthlyDeposit) && quiz.choice(for: .monthlyDeposit) == 1)
        #expect(quiz.failure == (offline ? .connectionLost : FakeRiskProfileService.problem))
        #expect(quiz.failure?.isConnectionLoss == offline)
        await quiz.retry()
        #expect(quiz.failure == nil && quiz.stage == .result(.moderate))
        #expect(await service.sent == [Self.persona, Self.persona])
    }

    @Test("Hasil Kuis opens on the saved profile and fills its answers in; none saved opens the quiz")
    func savedResult() async {
        await service.configure { $0.saved = SavedRiskProfile(profile: .aggressive, answers: RiskAnswers([2, 2, 3, 3, 3])) }
        let quiz = model(start: .savedResult)
        await quiz.load()
        #expect(quiz.stage == .result(.aggressive))
        quiz.restart()
        #expect(quiz.choice(for: .goal) == 2)
        await service.configure { $0.saved = nil }
        let fresh = model(start: .savedResult)
        await fresh.load()
        #expect(fresh.stage == .question(.goal) && fresh.choice(for: .goal) == nil)
    }

    @Test("an answer already chosen in this session wins over the saved ones")
    func draftWins() async {
        await service.configure { $0.saved = SavedRiskProfile(profile: .aggressive, answers: RiskAnswers([2, 2, 3, 3, 3])) }
        let quiz = model(RiskQuizDraft(answers: RiskAnswers(Self.persona)))
        await quiz.load()
        #expect(quiz.choice(for: .goal) == 1 && quiz.stage == .question(.goal))
    }

    @Test("an unreadable plan never blocks the quiz; an unreadable profile fails only Hasil Kuis")
    func unreadable() async {
        await service.configure { $0.readFailure = FakeRiskProfileService.problem }
        await plans.configure { $0.failing[.plan] = FakeGoalService.problem }
        let quiz = model()
        await quiz.load()
        #expect(quiz.phase.value == .unknown)
        let result = model(start: .savedResult)
        await result.load()
        guard case .failed(let problem) = result.phase else {
            Issue.record("expected failed")
            return
        }
        #expect(problem == FakeRiskProfileService.problem)
    }
}
