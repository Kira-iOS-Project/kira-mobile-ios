import Testing

@testable import Domain

/** Receipts as Vision really returns them: split rows, letters for digits, Indonesian amount shorthand. */
@Suite("ReceiptTextParser on noisy OCR")
struct ReceiptOCRTests {
    @Test("a minimarket receipt with TOTAL on its own line, TOTAL BAYAR, PPN and change")
    func minimarket() throws {
        let lines = [
            "ALFAMART", "JL. RAYA BOGOR KM 30", "NPWP 01.234.567.8-901.000", "17/10/2026 09:41 KSR 02",
            "INDOMIE GORENG", "3 x 3.100 9.300", "TEH BOTOL 450ML 5.500", "PPN 11% 1.650", "TOTAL", "Rp16.450",
            "TUNAI 20.000", "KEMBALI 3.550",
        ]
        let reading = try #require(ReceiptTextParser.read(lines))
        #expect(reading.storeName == "Alfamart")
        #expect(reading.printedAt == ReceiptDate(day: 17, month: 10, year: 2026, hour: 9, minute: 41))
        #expect(reading.items.map(\.name) == ["Indomie Goreng", "Teh Botol 450ml"])
        #expect(reading.items.map(\.amount) == [9_300, 5_500])
        #expect(reading.total == 16_450)
        let lines2 = ["Nasi Goreng 25.000", "TOTAL BAYAR 25.000", "BAYAR 50.000"]
        let total = try #require(ReceiptTextParser.read(lines2))
        #expect(total.total == 25_000 && total.items.map(\.amount) == [25_000])
    }

    @Test("amounts as Indonesians write them: 25.000,-, 25rb, 25k, IDR, 25,000 and digits read as letters")
    func amounts() throws {
        let lines = [
            "WARUNG BU SRI", "Es Teh 5.000,-", "Nasi Rames 25rb", "Kerupuk 2k", "Ayam Bakar IDR 18.000",
            "Sambal 3,000", "Tempe Rp1O.OOO", "GRAND TOTAL 63.000",
        ]
        let reading = try #require(ReceiptTextParser.read(lines))
        #expect(reading.items.map(\.amount) == [5_000, 25_000, 2_000, 18_000, 3_000, 10_000])
        #expect(reading.items.map(\.name) == ["Es Teh", "Nasi Rames", "Kerupuk", "Ayam Bakar", "Sambal", "Tempe"])
        #expect(reading.total == 63_000 && reading.balanced(otherName: "Lainnya") == reading)
    }

    @Test("a total OCR saw without readable items still reads; nothing at all does not")
    func totalOnly() throws {
        let reading = try #require(ReceiptTextParser.read(["KOPI KENANGAN", "x#%~ ;;", "JUMLAH 32.000"]))
        #expect(reading.items.isEmpty && reading.total == 32_000)
        #expect(reading.storeName == "Kopi Kenangan")
        #expect(ReceiptTextParser.read(["Terima kasih", "Selamat datang kembali"]) == nil)
    }

    @Test("TOTAL ITEM and KEMBALI are never the total; a minus before the total is ignored")
    func notTotals() throws {
        let lines = ["Roti 8.000", "TOTAL ITEM 1", "TOTAL QTY 2.000", "TOTAL KEMBALI 2.000", "TOTAL -8.000"]
        let reading = try #require(ReceiptTextParser.read(lines))
        #expect(reading.total == 8_000 && reading.items.map(\.amount) == [8_000])
    }

    @Test("the printed total wins: the gap becomes one line, and too much or nothing becomes the total")
    func balanced() {
        let date = ReceiptDate(day: 1, month: 10, year: 2026)
        let short = ReceiptReading(
            storeName: "A", printedAt: date, items: [ReceiptLine(name: "Roti", amount: 8_000)], total: 10_000)
        #expect(
            short.balanced(otherName: "Belanja").items == [
                ReceiptLine(name: "Roti", amount: 8_000), ReceiptLine(name: "Belanja", amount: 2_000),
            ])
        let over = ReceiptReading(
            storeName: nil, printedAt: nil, items: [ReceiptLine(name: "Roti", amount: 12_000)], total: 10_000)
        #expect(over.balanced(otherName: "Belanja").items == [ReceiptLine(name: "Belanja", amount: 10_000)])
        let none = ReceiptReading(storeName: nil, printedAt: nil, items: [], total: 32_000)
        #expect(none.balanced(otherName: "Belanja").items == [ReceiptLine(name: "Belanja", amount: 32_000)])
        #expect(short.balanced(otherName: "x").printedAt == date)
        let even = ReceiptReading(
            storeName: nil, printedAt: nil, items: [ReceiptLine(name: "A", amount: 1_000)], total: 1_000)
        #expect(even.balanced(otherName: "x") == even)
    }

    @Test("letters among digits are repaired, words are not")
    func repair() {
        #expect(ReceiptAmountText.repaired("Tempe Rp1O.OOO") == "Tempe Rp10.000")
        #expect(ReceiptAmountText.repaired("Roti 5.0OO") == "Roti 5.000")
        #expect(ReceiptAmountText.repaired("Oil Olive 600ml") == "Oil Olive 600ml")
        #expect(ReceiptAmountText.trailingAmount(of: "Teh") == nil)
    }
}
