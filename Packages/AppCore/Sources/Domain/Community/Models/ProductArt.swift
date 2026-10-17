/** The illustration beside a product, which the Kira team picks per product (`icon` of the API). */
package enum ProductArt: CaseIterable, Sendable {
    /** A book, the boards' course. */
    case book
    /** A card paid off, the boards' debt consultation. */
    case cardPaidOff
    /** A piggy bank, the boards' emergency-fund e-book. */
    case piggyBank
    /** People together, the boards' webinar. */
    case community

    /** The API's name of each illustration, the design system's word for it. */
    package init?(apiName: String) {
        switch apiName {
        case "buku": self = .book
        case "kartu-lunas": self = .cardPaidOff
        case "celengan": self = .piggyBank
        case "komunitas": self = .community
        default: return nil
        }
    }
}

extension ProductKind {
    /** The illustration the boards draw for this kind, for a name this build does not know. */
    package var defaultArt: ProductArt {
        switch self {
        case .course: .book
        case .consultation: .cardPaidOff
        case .ebook: .piggyBank
        case .event: .community
        }
    }
}
