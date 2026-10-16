/** Etalase's calls: the list by kind, one product, and every problem they answer. */
import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

private let summaryJSON = #"""
    {"id":"6f1c2b9e-0000-4000-8000-000000000001","kind":"course","title":"Kelas Budgeting Gaji Pertama",
     "sellerName":"Raka Aditya","sellerInitials":"RA","sellerBadge":"Perencana Bersertifikat","price":149000,
     "icon":"buku"}
    """#

private func detailJSON(sellerUrl: String, icon: String = "buku", price: String = "149000") -> String {
    #"""
    {"id":"6f1c2b9e-0000-4000-8000-000000000002","kind":"consultation","title":"Pendampingan Negosiasi Utang",
     "sellerName":"Dewi Anggraini","sellerInitials":"D","sellerBadge":"Terverifikasi","price":\#(price),
     "icon":"\#(icon)","description":"Didampingi menyusun permintaan keringanan.","meta":"1 sesi · 45 menit",
     "sellerRole":"Pendamping utang terverifikasi","contentsTitle":"Yang Kamu Dapatkan",
     "contents":["Membaca kondisi utangmu bersama-sama","Menentukan urutan pelunasan"],
     "affiliate":false,"investmentRisk":true,"sellerUrl":\#(sellerUrl)}
    """#
}

@Suite("MarketplaceAPI")
struct MarketplaceAPITests {
    @Test("lists the products of every kind, in the order sent")
    func listsAll() async throws {
        let (api, transport) = KiraAPI.canned(json: #"{"products":[\#(summaryJSON)]}"#)
        let products = try await api.listCommunityProducts(kind: nil)
        #expect(
            products == [
                ProductSummary(
                    id: "6f1c2b9e-0000-4000-8000-000000000001", kind: .course, title: "Kelas Budgeting Gaji Pertama",
                    sellerName: "Raka Aditya", sellerInitials: "RA", sellerBadge: "Perencana Bersertifikat",
                    price: 149_000, art: .book)
            ])
        let request = try #require(await transport.request)
        #expect(request.method == .get && request.path.hasSuffix("community/products"))
    }

    @Test("asks for one kind with the query", arguments: [
        (ProductKind.course, "course"), (.consultation, "consultation"), (.ebook, "ebook"), (.event, "event"),
    ])
    func filtersByKind(kind: ProductKind, query: String) async throws {
        let (api, transport) = KiraAPI.canned(json: #"{"products":[]}"#)
        #expect(try await api.listCommunityProducts(kind: kind).isEmpty)
        #expect(try #require(await transport.request).path.hasSuffix("community/products?kind=\(query)"))
    }

    @Test("reads one product with its seller link and flags; a free one has no price")
    func readsProduct() async throws {
        let (api, transport) = KiraAPI.canned(
            json: detailJSON(sellerUrl: #""https://penjual.example.id/negosiasi""#, icon: "kartu-lunas", price: "null"))
        let product = try await api.getCommunityProduct(id: "6f1c2b9e-0000-4000-8000-000000000002")
        #expect(product.summary.kind == .consultation && product.summary.isFree && product.summary.art == .cardPaidOff)
        #expect(product.meta == "1 sesi · 45 menit" && product.contents.count == 2)
        #expect(!product.affiliate && product.investmentRisk)
        #expect(product.sellerURL == URL(string: "https://penjual.example.id/negosiasi"))
        #expect(
            try #require(await transport.request).path.hasSuffix("products/6f1c2b9e-0000-4000-8000-000000000002"))
    }

    @Test("a seller link that is null or not a web page is no link; an unknown icon is the kind's", arguments: [
        "null", #""mailto:penjual@example.id""#, #""""#, #""penjual""#,
    ])
    func noSellerLink(sellerUrl: String) async throws {
        let (api, _) = KiraAPI.canned(json: detailJSON(sellerUrl: sellerUrl, icon: "tunas"))
        let product = try await api.getCommunityProduct(id: "p")
        #expect(product.sellerURL == nil && product.summary.art == .cardPaidOff)
    }

    @Test("a product that is gone, a lost session and a refused query throw the API's problem", arguments: [
        (404, "COMMUNITY_PRODUCT_NOT_FOUND"), (401, "AUTH_UNAUTHENTICATED"), (422, "VALIDATION_FAILED"),
    ])
    func productProblems(status: Int, code: String) async throws {
        let (api, _) = KiraAPI.canned(status: status, json: problemJSON(code))
        let error = await #expect(throws: AppProblem.self) { try await api.getCommunityProduct(id: "p") }
        #expect(error?.code == code)
    }

    @Test("the list throws a lost session and a refused query as the API's problem", arguments: [
        (401, "AUTH_UNAUTHENTICATED"), (422, "VALIDATION_FAILED"),
    ])
    func listProblems(status: Int, code: String) async throws {
        let (api, _) = KiraAPI.canned(status: status, json: problemJSON(code))
        let error = await #expect(throws: AppProblem.self) { try await api.listCommunityProducts(kind: nil) }
        #expect(error?.code == code)
    }

    @Test("any other answer throws the problem it carries")
    func otherStatus() async throws {
        await expectProblems([503]) { _ = try await $0.listCommunityProducts(kind: nil) }
        await expectProblems([503]) { _ = try await $0.getCommunityProduct(id: "p") }
    }
}
