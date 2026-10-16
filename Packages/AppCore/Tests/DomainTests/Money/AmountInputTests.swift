import Testing

@testable import Domain

@Suite("AmountInput")
struct AmountInputTests {
    @Test(
        "keeps the digits and groups them by three",
        arguments: [
            ("18000", "18.000"), ("Rp18.000", "18.000"), ("1250000", "1.250.000"), ("500", "500"), ("", ""),
            ("abc", ""), ("007", "7"), ("1234567890123", "123.456.789.012"),
        ])
    func grouped(typed: String, shown: String) {
        #expect(AmountInput.grouped(typed) == shown)
    }

    @Test("reads whole rupiah, nil without a digit")
    func amount() {
        #expect(AmountInput.amount("18.000") == 18_000)
        #expect(AmountInput.amount("Rp") == nil)
        #expect(AmountInput.amount("0") == nil)
    }

    @Test("writes a saved amount the way the field shows it")
    func text() {
        #expect(AmountInput.text(for: 7_500_000) == "7.500.000")
    }
}
