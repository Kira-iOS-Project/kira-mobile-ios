import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** The API's side of Riwayat Kira Score, answered per range from memory; it counts its calls. */
private final class FakeHistoryService: ScoreService, @unchecked Sendable {
    var answers: [ScoreHistoryRange: Result<ScoreHistory?, any Error>] = [:]
    private(set) var asked: [ScoreHistoryRange] = []
    /** Runs before an answer, to change the screen while a call is on its way. */
    var during: (@MainActor () async -> Void)?

    func score() throws -> ScoreReport? { nil }
    func indicator(_: IndicatorKey) throws -> IndicatorDetail { throw AppProblem() }
    func history(_ range: ScoreHistoryRange) async throws -> ScoreHistory? {
        asked.append(range)
        if let during { await during() }
        return try (answers[range] ?? .success(nil)).get()
    }
}

@MainActor
@Suite("ScoreHistoryModel")
struct ScoreHistoryModelTests {
    private func history(_ score: Int) -> ScoreHistory {
        ScoreHistory(
            score: score, band: .coping, deltaFromPrevious: nil, previousMonth: nil,
            points: [ScoreHistoryPoint(month: CalendarDay(year: 2026, month: 10, day: 1), score: score)], changes: [],
            unchangedCount: 0)
    }

    @Test("6 Bulan loads first; 1 Tahun loads once, then both show from memory")
    func ranges() async {
        let service = FakeHistoryService()
        service.answers = [.sixMonths: .success(history(66)), .oneYear: .success(history(67))]
        let model = ScoreHistoryModel(service: service)
        await model.load()
        #expect(model.range == .sixMonths && model.phase.value?.score == 66)
        await model.select(.oneYear)
        #expect(model.phase.value?.score == 67 && !model.isSwitching)
        await model.select(.sixMonths)
        await model.select(.oneYear)
        await model.select(.oneYear)
        #expect(model.phase.value?.score == 67 && service.asked == [.sixMonths, .oneYear])
    }

    @Test("before the health check the screen is empty")
    func empty() async {
        let model = ScoreHistoryModel(service: FakeHistoryService())
        await model.load()
        guard case .empty = model.phase else { return #expect(Bool(false)) }
    }

    @Test(
        "a failed load shows the API's problem, a lost connection as such; Coba Lagi loads again",
        arguments: [
            (AppProblem(code: "SCORE_NOT_AVAILABLE") as any Error, ProblemCode.scoreNotAvailable as ProblemCode?),
            (URLError(.notConnectedToInternet) as any Error, nil),
        ] as [(any Error, ProblemCode?)])
    func fails(error: any Error, code: ProblemCode?) async {
        let service = FakeHistoryService()
        service.answers = [.sixMonths: .failure(error)]
        let model = ScoreHistoryModel(service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem.knownCode == code && problem.isConnectionLoss == (code == nil))
        service.answers = [.sixMonths: .success(history(66))]
        await model.load()
        #expect(model.phase.value?.score == 66)
    }

    @Test("switching keeps the last range on screen; an answer for a range left behind is not shown")
    func switching() async {
        let service = FakeHistoryService()
        service.answers = [.sixMonths: .success(history(66)), .oneYear: .success(history(67))]
        let model = ScoreHistoryModel(service: service)
        await model.load()
        service.during = {
            #expect(model.isSwitching && model.phase.value?.score == 66)
            service.during = nil
            await model.select(.sixMonths)
        }
        await model.select(.oneYear)
        #expect(model.range == .sixMonths && model.phase.value?.score == 66)
        await model.select(.oneYear)
        #expect(model.phase.value?.score == 67 && service.asked == [.sixMonths, .oneYear])
    }

    @Test("a failed 1 Tahun shows its problem, and 6 Bulan comes back from memory")
    func switchFails() async {
        let service = FakeHistoryService()
        service.answers = [.sixMonths: .success(history(66)), .oneYear: .failure(AppProblem(code: "INTERNAL_ERROR"))]
        let model = ScoreHistoryModel(service: service)
        await model.load()
        await model.select(.oneYear)
        guard case .failed = model.phase else { return #expect(Bool(false)) }
        await model.select(.sixMonths)
        #expect(model.phase.value?.score == 66)
    }
}
