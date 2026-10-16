import Domain
import Foundation

/**
 Fills in a receipt's store name from the on-device model's look at the photo, only when the parser
 found none in the text and only when the model's name is printed on the receipt, so the model can
 add a name but never invent one. Items, amounts and the total always come from OCR and the parser.
 */
package struct ReceiptStoreAssist: Sendable {
    private let assistant: (any ReceiptAssisting)?

    /** The assist with the device's model, or none before iOS 27. */
    package init(assistant: (any ReceiptAssisting)?) {
        self.assistant = assistant
    }

    /** `reading` with the store's name the model found on `lines`, when the parser found none. */
    package func named(_ reading: ReceiptReading, lines: [String], image: Data) async -> ReceiptReading {
        guard reading.storeName == nil, let assistant, let name = await assistant.glance(at: image)?.storeName
        else { return reading }
        let wanted = Self.normalized(name)
        guard !wanted.isEmpty, Self.normalized(lines.joined(separator: " ")).contains(wanted) else { return reading }
        let words = SensitiveNumbers.masked(name).split(whereSeparator: \.isWhitespace).map(String.init)
        return ReceiptReading(
            storeName: NameCasing.titleCased(words, keepsAcronyms: false), printedAt: reading.printedAt,
            items: reading.items, total: reading.total)
    }

    /** Lower case, letters and digits only, single spaces: how a printed name is compared. */
    static func normalized(_ text: String) -> String {
        text.lowercased().split(whereSeparator: { !$0.isLetter && !$0.isNumber }).joined(separator: " ")
    }
}
