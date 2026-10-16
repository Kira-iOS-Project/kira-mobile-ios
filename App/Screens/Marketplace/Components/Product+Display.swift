/**
 How Etalase and Detail Produk show a product's kind and art: the chip and overline words, the
 education notice's sentence, the illustration and the seller's avatar tone, as the boards draw them.
 */
import Domain
import Foundation

extension ProductKind {
    /** "Kursus", "Konsultasi", "E-Book", "Event": the chip, the card's overline, the nav subtitle. */
    var title: LocalizedStringResource {
        switch self {
        case .course: "marketplace.kind.course"
        case .consultation: "marketplace.kind.consultation"
        case .ebook: "marketplace.kind.ebook"
        case .event: "marketplace.kind.event"
        }
    }

    /** "Kelas ini edukasi umum, …": the education notice of Detail Produk, by what the board calls it. */
    var educationMessage: LocalizedStringResource {
        switch self {
        case .course: "product.education.course"
        case .consultation: "product.education.consultation"
        case .ebook: "product.education.ebook"
        case .event: "product.education.event"
        }
    }

    /** The seller's avatar tone the boards give each kind. */
    var avatarTone: KiraAvatar.Tone {
        switch self {
        case .course: .sky
        case .consultation: .green
        case .ebook, .event: .peach
        }
    }
}

extension ProductArt {
    /** The design system's illustration. */
    var illustration: KiraIllustrationName {
        switch self {
        case .book: .book
        case .cardPaidOff: .cardPaidOff
        case .piggyBank: .piggyBank
        case .community: .community
        }
    }
}
