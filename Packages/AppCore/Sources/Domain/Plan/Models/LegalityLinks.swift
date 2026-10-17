import Foundation

/**
 The official places Cek Legalitas (REN-09) sends a person to. Satgas PASTI, IASC and Kontak OJK
 157 come from the verified contacts the app ships (`CareContactList.shipped`); the two OJK lists
 open OJK's own site at the host the board writes (ojk.go.id), never a guessed deeper path.
 */
package enum LegalityLinks {
    /** OJK's site, for Daftar Pindar Berizin OJK and Daftar Entitas Investasi Berizin OJK. */
    package static let ojk = URL(string: "https://ojk.go.id")

    /** Satgas PASTI's site (sipasti.ojk.go.id). */
    package static var satgasPasti: URL? { CareContactList.shipped.contact(.satgasPasti)?.website }

    /** Kontak OJK 157, its call and its WhatsApp. */
    package static var ojk157: CareContact? { CareContactList.shipped.contact(.ojk157) }
}
