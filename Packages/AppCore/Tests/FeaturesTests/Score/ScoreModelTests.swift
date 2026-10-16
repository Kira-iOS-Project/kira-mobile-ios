import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** The API's side of the score, answered from memory: the network is the boundary replaced here. */
private struct FakeScoreService: ScoreService {
    var report: Result<ScoreReport?, AppProblem> = .success(nil)
    var detail: Result<IndicatorDetail, AppProblem> = .failure(AppProblem(code: "ROUTE_NOT_FOUND"))

    func score() async throws -> ScoreReport? { try report.get() }
    func indicator(_ key: IndicatorKey) async throws -> IndicatorDetail {
        let detail = try detail.get()
        guard detail.indicator.key == key else { throw AppProblem(code: "VALIDATION_FAILED") }
        return detail
    }
}

private struct OtherError: Error {}

/** A service that fails with something other than an `AppProblem`. */
private struct BrokenScoreService: ScoreService {
    func score() async throws -> ScoreReport? { throw OtherError() }
    func indicator(_: IndicatorKey) async throws -> IndicatorDetail { throw OtherError() }
}

@MainActor
@Suite("ScoreModel and IndicatorModel")
struct ScoreModelTests {
    private let report = ScoreReport(
        score: Score(66), band: .coping, delta: 4, isInitial: false, computedAt: Date(timeIntervalSince1970: 0),
        nextCheckOn: Date(timeIntervalSince1970: 0), groups: [], indicators: [], steps: [],
        cappedByConsumerDebt: false)

    private let detail = IndicatorDetail(
        indicator: Indicator(
            key: .protection, group: .protect, points: Score(100), band: .healthy,
            measure: .protection(ProtectionMeasure(health: true, income: true))),
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
