import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("PortfolioModel")
struct PortfolioModelTests {
    @Test("loads the assets with their shares and the composition, and the eye hides the amounts")
    func loads() async {
        let model = PortfolioModel(service: FakePortfolioService())
        #expect(model.phase.value == nil && model.assetShares.isEmpty && model.classShares.isEmpty)
        await model.load()
        #expect(model.phase.value?.total == 2_400_000)
        #expect(model.assetShares == ["gold": 100])
        #expect(model.classShares == [ClassShare(assetClass: .gold, percent: 100)])
        #expect(!model.isMasked)
        model.toggleMasked()
        #expect(model.isMasked)
        #expect(PortfolioModel(service: FakePortfolioService(), isMasked: true).isMasked)
    }

    @Test("no asset is the empty portfolio")
    func empty() async {
        let none = FakePortfolioService.portfolio([])
        let model = PortfolioModel(service: FakePortfolioService(portfolios: [.success(none)]))
        await model.load()
        guard case .empty = model.phase else { return #expect(Bool(false)) }
    }

    @Test("a failed first load fails the screen; a failed reload keeps what is shown")
    func failures() async {
        let lost = PortfolioModel(service: FakePortfolioService(portfolios: [.failure(.connectionLost)]))
        await lost.load()
        guard case .failed(let problem) = lost.phase else { return #expect(Bool(false)) }
        #expect(problem.isConnectionLoss && !lost.needsPlan)
        let service = FakePortfolioService(
            portfolios: [.success(FakePortfolioService.sample), .failure(.connectionLost)])
        let shown = PortfolioModel(service: service)
        await shown.load()
        await shown.load()
        #expect(shown.phase.value?.assets == [FakePortfolioService.gold])
        #expect(!shown.needsPlan)
    }

    @Test("a plan without Portofolio asks for Paket Kira")
    func needsPlan() async {
        let refused = AppProblem(code: ProblemCode.planFeatureUnavailable.rawValue)
        let model = PortfolioModel(service: FakePortfolioService(portfolios: [.failure(refused)]))
        await model.load()
        #expect(model.needsPlan)
    }
}
