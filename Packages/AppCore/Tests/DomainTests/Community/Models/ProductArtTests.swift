import Testing

@testable import Domain

@Suite("ProductArt")
struct ProductArtTests {
    @Test(
        "reads the API's four names and nothing else",
        arguments: [
            ("buku", ProductArt.book), ("kartu-lunas", .cardPaidOff), ("celengan", .piggyBank),
            ("komunitas", .community),
        ])
    func apiName(name: String, art: ProductArt) {
        #expect(ProductArt(apiName: name) == art)
    }

    @Test("an unknown name is nil")
    func unknown() {
        #expect(ProductArt(apiName: "tunas") == nil)
    }

    @Test(
        "each kind has the boards' illustration",
        arguments: [
            (ProductKind.course, ProductArt.book), (.consultation, .cardPaidOff), (.ebook, .piggyBank),
            (.event, .community),
        ])
    func defaults(kind: ProductKind, art: ProductArt) {
        let product = ProductSummary(
            id: "p", kind: kind, title: "t", sellerName: "s", sellerInitials: "S", sellerBadge: "b", price: nil)
        #expect(kind.defaultArt == art && product.art == art)
        let picked = ProductSummary(
            id: "p", kind: kind, title: "t", sellerName: "s", sellerInitials: "S", sellerBadge: "b", price: nil,
            art: .community)
        #expect(picked.art == .community)
    }
}
