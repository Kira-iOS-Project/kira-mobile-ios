/** AmountInput reads and groups whole rupiah typed into a quiz field (ONB-10). */
import Testing

@testable import Domain

@Suite("AmountInput reads and groups typed rupiah")
struct AmountInputQuizTests {
    @Test(
        "only digits count, up to twelve",
        arguments: [
            ("", nil),
            ("abc", nil),
            ("7500000", 7_500_000),
            ("7.500.000", 7_500_000),
            ("Rp 25.000,", 25000),
            ("0", 0),
            ("1234567890123", 123_456_789_012),
        ] as [(String, Int?)])
    func value(_ text: String, _ expected: Int?) {
        #expect(AmountInput.value(of: text) == expected)
    }

    @Test(
        "the field shows the digits grouped with dots",
        arguments: [("", ""), ("x", ""), ("7500000", "7.500.000"), ("7.5000", "75.000"), ("420", "420")])
    func grouped(_ text: String, _ expected: String) {
        #expect(AmountInput.grouped(text) == expected)
    }

    @Test("a field opening filled shows its amount grouped, or nothing")
    func text() {
        #expect(AmountInput.text(for: 1_150_000) == "1.150.000")
        #expect(AmountInput.text(for: nil).isEmpty)
    }
}
