import Foundation

/**
 Kirim Produk ke Etalase (KOM-08): a seller proposes a product by email; the Kira team checks the
 seller's licence or certification before it shows. There is no form in the app.
 */
package enum ProductSubmission {
    /** The Kira team's address for Etalase proposals. */
    package static let address = "etalase@kira.id"

    /**
     The `mailto:` link that opens the mail app on a new message to `address` with `subject`, and a
     body that opens with `greeting` and lists `items` numbered, each followed by a colon to fill in.
     */
    package static func mailURL(subject: String, greeting: String, items: [String]) -> URL? {
        let list = items.enumerated().map { "\($0.offset + 1). \($0.element):" }
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = address
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: ([greeting, ""] + list).joined(separator: "\n")),
        ]
        return components.url
    }
}
