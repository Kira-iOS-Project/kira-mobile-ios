import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("LiveMarketplaceService")
struct LiveMarketplaceServiceTests {
    private let list = #"""
        {"products":[{"id":"a","kind":"ebook","title":"E-Book Dana Darurat Keluarga Muda","sellerName":"Sari Wulandari",
         "sellerInitials":"SW","sellerBadge":"Terverifikasi","price":49000,"icon":"celengan"}]}
        """#

    @Test("Etalase loads GET /community/products and a chip asks for its kind")
    func products() async throws {
        let (api, transport) = KiraAPI.routed(["GET /api/community/products": ok(list)])
        let model = MarketplaceModel(service: LiveMarketplaceService(api: api))
        await model.load()
        #expect(model.phase.value?.map(\.title) == ["E-Book Dana Darurat Keluarga Muda"])
        await model.select(.ebook)
        #expect(model.phase.value?.first?.art == .piggyBank)
        #expect(await transport.routes == ["GET /api/community/products", "GET /api/community/products"])
    }

    @Test("a product that is gone (COMMUNITY_PRODUCT_NOT_FOUND) empties Detail Produk")
    func productGone() async throws {
        let (api, _) = KiraAPI.routed([
            "GET /api/community/products/lama": problem("COMMUNITY_PRODUCT_NOT_FOUND", status: 404)
        ])
        let model = ProductModel(id: "lama", service: LiveMarketplaceService(api: api))
        await model.load()
        guard case .empty = model.phase else { return #expect(Bool(false)) }
    }

    @Test("a lost connection shows the connection message on both screens")
    func offline() async throws {
        let api = KiraAPI(serverURL: URL(filePath: "/"), transport: OfflineTransport())
        let service = LiveMarketplaceService(api: api)
        let marketplace = MarketplaceModel(service: service)
        await marketplace.load()
        guard case .failed(let listProblem) = marketplace.phase else { return #expect(Bool(false)) }
        #expect(listProblem.isConnectionLoss && !listProblem.showsReference)
        let product = ProductModel(id: "a", service: service)
        await product.load()
        guard case .failed(let detailProblem) = product.phase else { return #expect(Bool(false)) }
        #expect(detailProblem.isConnectionLoss)
    }

    @Test("a product loads in full through GET /community/products/{id}")
    func product() async throws {
        let detail = #"""
            {"id":"a","kind":"event","title":"Webinar Keuangan Keluarga Muda","sellerName":"Sari Wulandari",
             "sellerInitials":"SW","sellerBadge":"Terverifikasi","price":35000,"icon":"komunitas",
             "description":"Satu sore.","meta":"14 November 2026 · daring","sellerRole":"Penulis keuangan keluarga",
             "contentsTitle":"Yang Dibahas","contents":["Tanya jawab langsung dengan pembicara"],
             "affiliate":true,"investmentRisk":false,"sellerUrl":null}
            """#
        let (api, _) = KiraAPI.routed(["GET /api/community/products/a": ok(detail)])
        let model = ProductModel(id: "a", service: LiveMarketplaceService(api: api))
        await model.load()
        let product = try #require(model.phase.value)
        #expect(product.summary.kind == .event && product.affiliate && product.sellerURL == nil)
    }
}
