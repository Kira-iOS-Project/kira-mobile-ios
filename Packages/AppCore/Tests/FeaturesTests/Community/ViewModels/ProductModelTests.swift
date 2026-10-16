import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("ProductModel")
struct ProductModelTests {
    @Test("loads the product it was opened for")
    func loads() async {
        let model = ProductModel(
            id: "kelas-budgeting", service: FakeMarketplaceService(detail: .success(MarketplaceFixtures.detail)))
        #expect(model.id == "kelas-budgeting" && model.phase.value == nil)
        await model.load()
        #expect(model.phase.value == MarketplaceFixtures.detail)
    }

    @Test("a product no longer in Etalase is empty: COMMUNITY_PRODUCT_NOT_FOUND cannot be retried")
    func gone() async {
        let gone = ProductModel(
            id: "lama", service: FakeMarketplaceService(detail: .success(MarketplaceFixtures.detail)))
        await gone.load()
        guard case .empty = gone.phase else { return #expect(Bool(false)) }
    }

    @Test("another problem, and a lost connection, fail with what happened")
    func failures() async {
        let refused = ProductModel(
            id: "p", service: FakeMarketplaceService(detail: .failure(AppProblem(code: "AUTH_UNAUTHENTICATED"))))
        await refused.load()
        guard case .failed(let problem) = refused.phase else { return #expect(Bool(false)) }
        #expect(problem.knownCode == .authUnauthenticated)
        let offline = ProductModel(id: "kelas-budgeting", service: OfflineMarketplaceService())
        await offline.load()
        guard case .failed(let lost) = offline.phase else { return #expect(Bool(false)) }
        #expect(lost.isConnectionLoss)
    }

    @Test("Coba Lagi loads the same product again after a failure")
    func retry() async {
        let service = ScriptedMarketplaceService(
            details: [.failure(.connectionLost), .success(MarketplaceFixtures.detail)])
        let model = ProductModel(id: "p", service: service)
        await model.load()
        guard case .failed = model.phase else { return #expect(Bool(false)) }
        await model.load()
        #expect(model.phase.value == MarketplaceFixtures.detail)
    }
}
