import Testing

@testable import Domain

@Suite("ReceiptTextParser")
struct ReceiptTextParserTests {
    /** The board's receipt (ScanStruk), as Vision returns it line by line. */
    private let board = [
        "TOKO SEJAHTERA", "Jl. Melati No. 12, Jakarta", "15-10-2026 12:58", "--------",
        "Beras 5 Kg 72.000,00", "Minyak Goreng 2 L 38.000,00", "Sabun Cuci 15.500,00", "--------",
        "TOTAL 125.500,00", "TUNAI 150.000,00", "KEMBALI 24.500,00", "Terima kasih, sampai jumpa",
    ]

    @Test("the board's receipt: store, date, three items and the total")
    func boardReceipt() throws {
        let reading = try #require(ReceiptTextParser.read(board))
        #expect(reading.storeName == "Toko Sejahtera")
        #expect(reading.printedAt == ReceiptDate(day: 15, month: 10, year: 2026, hour: 12, minute: 58))
        #expect(reading.items.map(\.name) == ["Beras 5 Kg", "Minyak Goreng 2 L", "Sabun Cuci"])
        #expect(reading.items.map(\.amount) == [72_000, 38_000, 15_500])
        #expect(reading.total == 125_500)
        #expect(reading.isBalanced)
    }

    @Test("capitals, quantity lines, a discount, a subtotal and a card payment")
    func busyReceipt() throws {
        let lines = [
            "Jl. Kenanga 3", "INDOMARET CABANG KEMANG", "15/10/26", "AQUA 600ML", "2 x 3.500 7.000", "ROTI TAWAR 15.000",
            "DISKON -2.000", "SUBTOTAL 20.000", "PPN 2.000", "TOTAL Rp 22.000", "DEBIT 4111 1111 1111 1234 22.000",
        ]
        let reading = try #require(ReceiptTextParser.read(lines))
        #expect(reading.storeName == "Indomaret Cabang Kemang")
        #expect(reading.printedAt == ReceiptDate(day: 15, month: 10, year: 2026))
        #expect(reading.items.map(\.name) == ["Aqua 600ml", "Roti Tawar", "Ppn"])
        #expect(reading.items.map(\.amount) == [7_000, 13_000, 2_000])
        #expect(reading.total == 22_000)
        #expect(reading.isBalanced)
    }

    @Test("no total printed: the sum; unbalanced; nothing readable")
    func edges() throws {
        let noTotal = try #require(ReceiptTextParser.read(["Kopi Susu 18.000", "Donat 7.000"]))
        #expect(noTotal.total == 25_000)
        #expect(noTotal.storeName == nil)
        #expect(noTotal.printedAt == nil)
        let wrong = try #require(ReceiptTextParser.read(["Kopi 18.000", "Total 20.000"]))
        #expect(!wrong.isBalanced)
        #expect(ReceiptTextParser.read(["Terima kasih", "", "12:00", "---"]) == nil)
        #expect(ReceiptTextParser.read(["DISKON 2.000", "1 x 5.000"]) == nil)
    }

    @Test("a date with an impossible day or a time on another line")
    func dates() {
        #expect(ReceiptTextParser.printedDate(in: ["45-10-2026"]) == nil)
        #expect(ReceiptTextParser.printedDate(in: ["Kasir 2", "10.10.2026", "Jam 08:05"]) == ReceiptDate(
            day: 10, month: 10, year: 2026, hour: 8, minute: 5))
        #expect(ReceiptTextParser.printedDate(in: ["10-10-2026 99:99"])?.hour == nil)
    }

    @Test("store names skip addresses and lines with amounts")
    func store() {
        #expect(ReceiptTextParser.storeName(in: ["Telp 021", "Kopi 18.000", "WARUNG BU TINI"]) == "Warung Bu Tini")
        #expect(ReceiptTextParser.storeName(in: ["AB"]) == nil)
    }

    @Test("line kinds")
    func kinds() {
        #expect(ReceiptLineKind.of("Kopi: Rp. 18.000") == .priced(label: "Kopi", amount: 18_000))
        #expect(ReceiptLineKind.of("1 x 5.000") == .quantity(amount: 5_000))
        #expect(ReceiptLineKind.of("12:58") == .blank)
        #expect(ReceiptLineKind.of("Terima kasih") == .text("Terima kasih"))
        #expect(ReceiptLineKind.of("---") == .blank)
    }
}
