import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** The API's side of the score, answered from memory: the network is the boundary replaced here. */
private struct FakeScoreService: ScoreService {
    var report: Result<ScoreReport?, AppProblem> = .success(nil)
    var detail: Result<IndicatorDetail, AppProblem> = .failure(AppProblem(code: "ROUTE_NOT_FOUND"))
    var plus = true

    func score() throws -> ScoreReport? { try report.get() }
    func indicator(_ key: IndicatorKey) throws -> IndicatorDetail {
        let detail = try detail.get()
        guard detail.indicator.key == key else { throw AppProblem(code: "VALIDATION_FAILED") }
        return detail
    }
    func history(_: ScoreHistoryRange) throws -> ScoreHistory? { nil }
    func includesPlus() -> Bool { plus }
}

private struct OtherError: Error {}

/** A service that fails with something other than an `AppProblem`. */
private struct BrokenScoreService: ScoreService {
    func score() throws -> ScoreReport? { throw OtherError() }
    func indicator(_: IndicatorKey) throws -> IndicatorDetail { throw OtherError() }
    func history(_: ScoreHistoryRange) throws -> ScoreHistory? { throw OtherError() }
    func includesPlus() -> Bool { true }
}

@MainActor
@Suite("ScoreModel and IndicatorModel")
struct ScoreModelTests {
    private let report = ScoreReport(
        score: 66, band: .coping, computedAt: Date(timeIntervalSince1970: 0),
        nextCheckOn: Date(timeIntervalSince1970: 0))

    private let detail = IndicatorDetail(
        indicator: ScoreIndicator(
            key: .protection, group: .protect, points: 100, band: .healthy,
            measure: .protectionCover(health: true, income: true)),
        ladder: [], nextRung: nil, milestones: [])

    @Test("loads the score, or is empty before the health check")
    func score() async {
        let model = ScoreModel(service: FakeScoreService(report: .success(report)))
        #expect(model.phase.value == nil)
        await model.load()
        #expect(model.phase.value == report)
        let before = ScoreModel(service: FakeScoreService())
        await before.load()
        guard case .empty = before.phase else { return #expect(Bool(false)) }
    }

    @Test("Lihat Riwayat Skor opens the history on Kira Plus, Paket Kira on any other plan")
    func historyRoute() async {
        let plus = ScoreModel(service: FakeScoreService(report: .success(report)))
        #expect(plus.historyRoute == .scoreHistory)
        await plus.load()
        #expect(plus.historyRoute == .scoreHistory)
        var free = FakeScoreService(report: .success(report))
        free.plus = false
        let other = ScoreModel(service: free)
        await other.load()
        #expect(other.historyRoute == .plans(yearly: false))
    }

    @Test("shows the score's problem, or the generic one")
    func scoreFailure() async {
        let model = ScoreModel(service: FakeScoreService(report: .failure(AppProblem(code: "INTERNAL_ERROR"))))
        await model.load()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem.code == "INTERNAL_ERROR")
        let broken = ScoreModel(service: BrokenScoreService())
        await broken.load()
        guard case .failed(let generic) = broken.phase else { return #expect(Bool(false)) }
        #expect(generic == AppProblem())
    }

    @Test("loads the indicator it was opened for")
    func indicator() async {
        let model = IndicatorModel(key: .protection, service: FakeScoreService(detail: .success(detail)))
        #expect(model.key == .protection)
        await model.load()
        #expect(model.phase.value == detail)
    }

    @Test("shows the indicator's problem, or the generic one")
    func indicatorFailure() async {
        let model = IndicatorModel(key: .savingsRatio, service: FakeScoreService(detail: .success(detail)))
        await model.load()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem.code == "VALIDATION_FAILED")
        let broken = IndicatorModel(key: .protection, service: BrokenScoreService())
        await broken.load()
        guard case .failed(let generic) = broken.phase else { return #expect(Bool(false)) }
        #expect(generic == AppProblem())
    }
}
