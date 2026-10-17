import Foundation
import Testing

@testable import Domain

@Suite("ProductSubmission")
struct ProductSubmissionTests {
    @Test("the link writes to the Kira team with the subject and a numbered list to fill in")
    func mailURL() throws {
        let url = try #require(
            ProductSubmission.mailURL(
                subject: "Usulan Produk Etalase Kira", greeting: "Halo tim Kira,",
                items: ["Nama produk", "Harga, atau tulis gratis"]))
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.scheme == "mailto" && components.path == "etalase@kira.id")
        let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) })
        #expect(query["subject"] == "Usulan Produk Etalase Kira")
        #expect(query["body"] == "Halo tim Kira,\n\n1. Nama produk:\n2. Harga, atau tulis gratis:")
        #expect(url.absoluteString.hasPrefix("mailto:etalase@kira.id?subject=Usulan%20Produk%20Etalase%20Kira"))
    }
}
