import Foundation
import Testing

@testable import Domain

@Suite("Product")
struct ProductTests {
    private func summary(price: Int?) -> ProductSummary {
        ProductSummary(
            id: "p-1", kind: .consultation, title: "Pendampingan Negosiasi Utang", sellerName: "Dewi Anggraini",
            sellerInitials: "D", sellerBadge: "Terverifikasi", price: price)
    }

    @Test("a product with no price or a zero price is free; any price is not", arguments: [
        (Int?.none, true), (0, true), (35_000, false),
    ])
    func free(price: Int?, isFree: Bool) {
        #expect(summary(price: price).isFree == isFree)
    }

    @Test("the detail keeps its summary and every field")
    func detail() throws {
        let url = try #require(URL(string: "https://penjual.example.id/negosiasi"))
        let product = Product(
            summary: summary(price: nil), description: "Didampingi.", meta: "1 sesi · 45 menit",
            sellerRole: "Pendamping utang terverifikasi", contentsTitle: "Yang Kamu Dapatkan", contents: ["Satu"],
            affiliate: false, investmentRisk: true, sellerURL: url)
        #expect(product.summary.id == "p-1" && product.summary.kind == .consultation)
        #expect(product.meta == "1 sesi · 45 menit" && product.contents == ["Satu"])
        #expect(!product.affiliate && product.investmentRisk && product.sellerURL == url)
        #expect(product.description == "Didampingi." && product.sellerRole.hasPrefix("Pendamping"))
        #expect(product.contentsTitle == "Yang Kamu Dapatkan")
    }
}
