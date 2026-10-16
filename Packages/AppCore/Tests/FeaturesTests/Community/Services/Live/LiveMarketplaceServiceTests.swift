import APIClient
import Domain
import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@testable import Features

/** A network with no connection: every request fails before it reaches the server. */
private struct OfflineTransport: ClientTransport {
    func send(
        _: HTTPRequest, body _: HTTPBody?, baseURL _: URL, operationID _: String
    ) throws -> (HTTPResponse, HTTPBody?) {
        throw URLError(.notConnectedToInternet)
    }
}

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

    @Test("a product that is gone reaches Detail Produk as COMMUNITY_PRODUCT_NOT_FOUND")
    func productGone() async throws {
        let (api, _) = KiraAPI.routed([
            "GET /api/community/products/lama": problem("COMMUNITY_PRODUCT_NOT_FOUND", status: 404)
        ])
        let model = ProductModel(id: "lama", service: LiveMarketplaceService(api: api))
        await model.load()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem.knownCode == .communityProductNotFound)
        #expect(problem.messageKey == "problem.COMMUNITY_PRODUCT_NOT_FOUND")
    }

    @Test("a lost connection shows the generic problem on both screens, and Coba Lagi asks again")
    func offline() async throws {
        let api = KiraAPI(serverURL: URL(filePath: "/"), transport: OfflineTransport())
        let service = LiveMarketplaceService(api: api)
        let marketplace = MarketplaceModel(service: service)
        await marketplace.load()
        guard case .failed(let listProblem) = marketplace.phase else { return #expect(Bool(false)) }
        #expect(listProblem.knownCode == nil && listProblem.messageKey == "problem.unknown")
        let product = ProductModel(id: "a", service: service)
        await product.load()
        guard case .failed(let detailProblem) = product.phase else { return #expect(Bool(false)) }
        #expect(detailProblem.messageKey == "problem.unknown")
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
