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

    @Test("a gone product shows COMMUNITY_PRODUCT_NOT_FOUND; a lost connection the generic problem")
    func failures() async {
        let gone = ProductModel(
            id: "lama", service: FakeMarketplaceService(detail: .success(MarketplaceFixtures.detail)))
        await gone.load()
        guard case .failed(let problem) = gone.phase else { return #expect(Bool(false)) }
        #expect(problem.knownCode == nil && problem.code == "COMMUNITY_PRODUCT_NOT_FOUND")
        let offline = ProductModel(id: "kelas-budgeting", service: OfflineMarketplaceService())
        await offline.load()
        guard case .failed(let generic) = offline.phase else { return #expect(Bool(false)) }
        #expect(generic == AppProblem())
    }
}
