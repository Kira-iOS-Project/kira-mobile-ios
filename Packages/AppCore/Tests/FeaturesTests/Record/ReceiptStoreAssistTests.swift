import Domain
import Foundation
import Testing

@testable import Features

@Suite("ReceiptStoreAssist")
struct ReceiptStoreAssistTests {
    private let lines = ["TOKO SEJAHTERA", "Jl. Melati No. 12", "Beras 5 Kg 72.000,00", "TOTAL 72.000,00"]
    private let unnamed = ReceiptReading(
        storeName: nil, printedAt: ReceiptDate(day: 15, month: 10, year: 2026),
        items: [ReceiptLine(name: "Beras 5 Kg", amount: 72_000)], total: 72_000)

    @Test("the model's name fills a missing store when the receipt prints it; numbers stay the parser's")
    func fills() async {
        let assistant = FakeReceiptAssistant(ReceiptGlance(storeName: "toko  Sejahtera", kind: .receipt))
        let named = await ReceiptStoreAssist(assistant: assistant).named(unnamed, lines: lines, image: Data())
        #expect(named.storeName == "Toko Sejahtera")
        #expect(named.items == unnamed.items)
        #expect(named.total == 72_000)
        #expect(named.printedAt == unnamed.printedAt)
    }

    @Test("a name not printed on the receipt, an empty one, none, or no model leaves the reading as it is")
    func ignored() async {
        for glance in [
            ReceiptGlance(storeName: "Indomaret", kind: .receipt),
            ReceiptGlance(storeName: " · ", kind: .transferProof),
            ReceiptGlance(storeName: nil, kind: .receipt), nil,
        ] {
            let named = await ReceiptStoreAssist(assistant: FakeReceiptAssistant(glance))
                .named(unnamed, lines: lines, image: Data())
            #expect(named == unnamed)
        }
        #expect(await ReceiptStoreAssist(assistant: nil).named(unnamed, lines: lines, image: Data()) == unnamed)
    }

    @Test("the model is not asked when the parser found the store")
    func parserFirst() async {
        let assistant = FakeReceiptAssistant(ReceiptGlance(storeName: "Toko Lain", kind: .receipt))
        let named = ReceiptReading(storeName: "Toko Sejahtera", printedAt: nil, items: unnamed.items, total: 72_000)
        #expect(await ReceiptStoreAssist(assistant: assistant).named(named, lines: lines, image: Data()) == named)
        #expect(assistant.asked == 0)
    }
}
