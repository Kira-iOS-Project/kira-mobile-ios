import APIClient
import Domain
import Observation

/**
 Kenali Profil Risikomu (REN-06 to REN-06e) and its Hasil Kuis (REN-07), one screen: a question at
 a time, Lanjut once an option is chosen, Kembali to the question before (on the first it leaves
 the quiz), and Lihat Hasil, which sends the five answers for the server to score. While that save
 is on its way the button waits and a second tap does nothing; a failed save keeps the answers and
 shows the failure dialog, whose Coba Lagi sends them again. Ulangi Kuis starts again from the
 first question with the answers filled in. The plan's numbers never block the quiz: when they
 cannot be read it shows no ladder notice and the board's ranges.
 */
@MainActor
@Observable
package final class RiskQuizModel {
    /** What the screen shows. */
    package enum Stage: Hashable, Sendable {
        /** One question. */
        case question(RiskQuestion)
        /** Hasil Kuis with the server's profile. */
        case result(RiskProfile)
    }

    /** Where the screen opens. */
    package enum Start: Hashable, Sendable {
        /** The quiz, at `question`. */
        case quiz(RiskQuestion = .goal)
        /** Hasil Kuis of the saved profile, or the quiz when none is saved. */
        case savedResult
    }

    /** The plan's numbers once read (`RiskQuizContext.unknown` when unreadable), or the saved profile's problem. */
    package private(set) var phase: ScreenPhase<RiskQuizContext> = .loading
    /** The question or the result on screen. */
    package private(set) var stage: Stage
    /** Whether Lihat Hasil's save is on its way. */
    package private(set) var isSaving = false
    /** The problem of the last failed save, for the failure dialog; nil once it closes. */
    package var failure: AppProblem?
    /** True once Kembali on the first question leaves the quiz. */
    package private(set) var isClosed = false

    private let start: Start
    private let draft: RiskQuizDraft
    private let service: any RiskProfileService
    private let plans: (any GoalService)?

    /** A quiz on `service`, keeping its answers in `draft`, with the plan's numbers from `plans` (`GET /plan`; none: unknown). */
    package init(
        service: any RiskProfileService, draft: RiskQuizDraft, plans: (any GoalService)?, start: Start = .quiz()
    ) {
        self.service = service
        self.draft = draft
        self.plans = plans
        self.start = start
        if case .quiz(let question) = start { stage = .question(question) } else { stage = .question(.goal) }
    }

    /** Reads the plan's numbers and, for Hasil Kuis, the saved profile. */
    package func load() async {
        let numbers = (try? await plans?.plan()).map(RiskQuizContext.init(plan:)) ?? .unknown
        do {
            let saved = try await service.savedProfile()
            if draft.answers.indexes == nil, let saved { draft.answers = saved.answers }
            if start == .savedResult, let saved { stage = .result(saved.profile) }
            phase = .loaded(numbers)
        } catch {
            phase = start == .savedResult ? .failed(AppProblem(error)) : .loaded(numbers)
        }
    }

    /** The option chosen for `question`, if any. */
    package func choice(for question: RiskQuestion) -> Int? {
        draft.answers.choice(for: question)
    }

    /** Chooses `option` on the question on screen. */
    package func choose(_ option: Int) {
        guard case .question(let question) = stage else { return }
        draft.answers.choose(option, for: question)
    }

    /** Whether Lanjut (or Lihat Hasil) can be tapped: an option is chosen and no save is on its way. */
    package var canContinue: Bool {
        guard case .question(let question) = stage else { return false }
        return choice(for: question) != nil && !isSaving
    }

    /** Lanjut: the next question; on the last, Lihat Hasil saves the answers. */
    package func next() async {
        guard canContinue, case .question(let question) = stage else { return }
        if let next = question.next {
            stage = .question(next)
        } else {
            await submit()
        }
    }

    /** Kembali: the question before, its answer kept; on the first question the quiz closes. */
    package func back() {
        guard case .question(let question) = stage else { return }
        if let previous = question.previous { stage = .question(previous) } else { isClosed = true }
    }

    /** Coba Lagi on the failure dialog: the same answers again. */
    package func retry() async {
        failure = nil
        await submit()
    }

    /** Ulangi Kuis: the first question again, the answers filled in. */
    package func restart() {
        stage = .question(.goal)
    }

    private func submit() async {
        guard !isSaving, let answers = draft.answers.indexes else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            stage = .result(try await service.saveRiskProfile(answers: answers))
        } catch {
            failure = AppProblem(error)
        }
    }
}
