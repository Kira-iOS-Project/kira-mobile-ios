import Testing

@testable import Domain

@Suite("TextFragmentLines")
struct TextFragmentLinesTests {
    @Test("pieces on one row join left to right; rows go top to bottom")
    func lines() {
        let fragments = [
            TextFragment(text: "72.000,00", minX: 0.7, midY: 0.301, height: 0.02),
            TextFragment(text: "TOKO SEJAHTERA", minX: 0.3, midY: 0.1, height: 0.03),
            TextFragment(text: "Beras 5 Kg", minX: 0.1, midY: 0.3, height: 0.02),
            TextFragment(text: "TOTAL", minX: 0.1, midY: 0.5, height: 0.02),
        ]
        #expect(TextFragmentLines.lines(of: fragments) == ["TOKO SEJAHTERA", "Beras 5 Kg 72.000,00", "TOTAL"])
        #expect(TextFragmentLines.lines(of: []).isEmpty)
    }
}
