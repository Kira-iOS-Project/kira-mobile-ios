import Foundation
import Testing

@testable import Domain

@Suite("LegalityLinks")
struct LegalityLinksTests {
    @Test("OJK's root, Satgas PASTI's site and OJK 157's numbers from the shipped contacts")
    func links() {
        #expect(LegalityLinks.ojk?.absoluteString == "https://ojk.go.id")
        #expect(LegalityLinks.satgasPasti?.absoluteString == "https://sipasti.ojk.go.id")
        #expect(LegalityLinks.ojk157?.callURL?.absoluteString == "tel:157")
        #expect(LegalityLinks.ojk157?.whatsAppURL(message: nil)?.absoluteString == "https://wa.me/6281157157157")
    }
}
