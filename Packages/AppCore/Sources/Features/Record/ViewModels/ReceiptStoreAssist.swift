import Domain
import Foundation

/**
 Fills in a receipt's store name from the on-device model's look at the photo, only when the parser
 found none in the text and only when the model's name is printed on the receipt, so the model can
 add a name but never invent one. Items, amounts and the total always come from OCR and the parser.
 */
package struct ReceiptStoreAssist: Sendable {
    private let assistant: (any ReceiptAssisting)?
    /** How long the model may look before the receipt goes without its name. */
    private let timeout: Duration

    /** The assist with the device's model, or none before iOS 27; the model gets `timeout` to answer. */
    package init(assistant: (any ReceiptAssisting)?, timeout: Duration = .seconds(4)) {
        self.assistant = assistant
        self.timeout = timeout
    }

    /** The model's glance, or nil when it takes longer than `timeout`: the parser's reading goes on. */
    private static func glance(_ assistant: any ReceiptAssisting, at image: Data, within timeout: Duration) async
        -> ReceiptGlance?
    {
        await withTaskGroup(of: ReceiptGlance?.self) { group in
            group.addTask { await assistant.glance(at: image) }
            group.addTask {
                try? await Task.sleep(for: timeout)
                return nil
            }
            let first = await group.next().flatMap { $0 }
            group.cancelAll()
            return first
        }
    }

    /** `reading` with the store's name the model found on `lines`, when the parser found none. */
    package func named(_ reading: ReceiptReading, lines: [String], image: Data) async -> ReceiptReading {
        guard reading.storeName == nil, let assistant else { return reading }
        guard let name = await Self.glance(assistant, at: image, within: timeout)?.storeName else { return reading }
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
