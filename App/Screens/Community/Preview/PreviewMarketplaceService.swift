/**
 Etalase's API answered with the boards' products (Etalase, DetailProduk and its Konsultasi, E-Book
 and Event variants), so the screens run in previews and in the app before integration.
 */
import APIClient
import Domain
import Features
import Foundation
import SwiftUI

nonisolated extension ProductSummary {
    /** The four products, in the team's order. */
    static let samples = [
        ProductSummary(
            id: "budgeting-first-salary", kind: .course, title: "Kelas Budgeting Gaji Pertama",
            sellerName: "Raka Aditya", sellerInitials: "RA", sellerBadge: "Perencana Bersertifikat", price: 149_000),
        ProductSummary(
            id: "debt-negotiation", kind: .consultation, title: "Pendampingan Negosiasi Utang",
            sellerName: "Dewi Anggraini", sellerInitials: "D", sellerBadge: "Terverifikasi", price: nil),
        ProductSummary(
            id: "family-emergency-fund", kind: .ebook, title: "E-Book Dana Darurat Keluarga Muda",
            sellerName: "Sari Wulandari", sellerInitials: "SW", sellerBadge: "Terverifikasi", price: 49_000),
        ProductSummary(
            id: "young-family-webinar", kind: .event, title: "Webinar Keuangan Keluarga Muda",
            sellerName: "Sari Wulandari", sellerInitials: "SW", sellerBadge: "Terverifikasi", price: 35_000),
    ]
}

nonisolated extension Product {
    /**
     The board's detail of each kind. The course has a seller page, as DetailProduk draws it enabled
     (on the reserved example.com, never a real seller); the others wait for the team's check.
     */
    static func sample(_ kind: ProductKind) -> Product {
        let summary = ProductSummary.samples.first { $0.kind == kind } ?? ProductSummary.samples[0]
        let text = PreviewProductText.of(kind)
        return Product(
            summary: summary, description: text.description, meta: text.meta, sellerRole: text.role,
            contentsTitle: text.contentsTitle, contents: text.contents, affiliate: true,
            investmentRisk: false,
            sellerURL: kind == .course ? URL(string: "https://example.com/kelas-budgeting") : nil)
    }
}

nonisolated struct PreviewMarketplaceService: MarketplaceService {
    /** The samples of each kind, as the API answers a chip. */
    private static let byKind = Dictionary(grouping: ProductSummary.samples, by: \.kind)

    func products(kind: ProductKind?) -> [ProductSummary] {
        kind.map { Self.byKind[$0] ?? [] } ?? ProductSummary.samples
    }

    func product(id: String) throws -> Product {
        guard let summary = ProductSummary.samples.first(where: { $0.id == id }) else {
            throw AppProblem(code: ProblemCode.communityProductNotFound.rawValue)
        }
        return .sample(summary.kind)
    }
}

#if DEBUG
    #Preview("Etalase") {
        NavigationStack { MarketplaceScreen(service: PreviewMarketplaceService()) { _ in } }
    }

    #Preview("Detail Produk") {
        NavigationStack { ProductScreen(id: "budgeting-first-salary", service: PreviewMarketplaceService()) { _ in } }
    }

    #Preview("Kirim Produk") {
        NavigationStack { SubmitProductScreen { _ in } }
    }
#endif
