import Foundation

/** One product of Etalase as the list shows it (`ProductSummary` of the API). */
package struct ProductSummary: Hashable, Identifiable, Sendable {
    /** The product's id, for its detail. */
    package let id: String
    /** Course, consultation, e-book or event. */
    package let kind: ProductKind
    /** The product's name, as the seller wrote it. */
    package let title: String
    /** The seller's name. */
    package let sellerName: String
    /** The seller's initials, for the avatar. */
    package let sellerInitials: String
    /** What the Kira team checked about the seller, such as "Perencana Bersertifikat". */
    package let sellerBadge: String
    /** The price in whole rupiah, or nil when the product is free ("Gratis", never Rp0,00). */
    package let price: Int?
    /** The illustration beside it. */
    package let art: ProductArt

    /** A product with every field; the illustration is the kind's unless the team picked one. */
    package init(
        id: String, kind: ProductKind, title: String, sellerName: String, sellerInitials: String,
        sellerBadge: String, price: Int?, art: ProductArt? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.sellerName = sellerName
        self.sellerInitials = sellerInitials
        self.sellerBadge = sellerBadge
        self.price = price
        self.art = art ?? kind.defaultArt
    }

    /** Whether the product costs nothing: the list and the detail show "Gratis". */
    package var isFree: Bool {
        price == nil || price == 0
    }
}

/** One product in full, for Detail Produk (`GET /community/products/{id}`). */
package struct Product: Hashable, Sendable {
    /** What the list shows. */
    package let summary: ProductSummary
    /** One or two sentences on what the product is. */
    package let description: String
    /** The product's size or date, such as "6 modul video" or "14 November 2026 · daring". */
    package let meta: String
    /** The seller's role under their name. */
    package let sellerRole: String
    /** The title over the contents, such as "Yang Kamu Pelajari". */
    package let contentsTitle: String
    /** Three or four points on what the product holds. */
    package let contents: [String]
    /** Whether Kira earns an affiliate commission on a purchase: the disclosure shows (POJK 6/2026). */
    package let affiliate: Bool
    /** Whether the product touches investing: the extra risk warning shows. */
    package let investmentRisk: Bool
    /**
     The seller's page, opened in the system browser (Kira never takes the payment), or nil while
     the curation team checks it again: "Buka Halaman Penjual" is then disabled.
     */
    package let sellerURL: URL?

    /** A product with every field. */
    package init(
        summary: ProductSummary, description: String, meta: String, sellerRole: String, contentsTitle: String,
        contents: [String], affiliate: Bool, investmentRisk: Bool, sellerURL: URL?
    ) {
        self.summary = summary
        self.description = description
        self.meta = meta
        self.sellerRole = sellerRole
        self.contentsTitle = contentsTitle
        self.contents = contents
        self.affiliate = affiliate
        self.investmentRisk = investmentRisk
        self.sellerURL = sellerURL
    }
}
