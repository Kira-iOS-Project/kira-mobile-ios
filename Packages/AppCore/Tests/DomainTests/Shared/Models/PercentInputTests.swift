import Testing

@testable import Domain

@Suite("PercentInput")
struct PercentInputTests {
    @Test(
        "keeps three whole digits, one decimal comma and two decimals",
        arguments: [
            ("36", "36"), ("2,5", "2,5"), ("2.5", "2,5"), ("12,345", "12,34"), ("1234", "123"),
            ("1,2,3", "1,23"), ("abc", ""), ("", ""), ("12,", "12,"), (",5", ",5"),
        ])
    func cleaned(typed: String, shown: String) {
        #expect(PercentInput.cleaned(typed) == shown)
    }

    @Test("reads the rate, nil when empty, without a digit or above 300")
    func value() {
        #expect(PercentInput.value(of: "36") == 36)
        #expect(PercentInput.value(of: "2,5") == 2.5)
        #expect(PercentInput.value(of: "12,") == 12)
        #expect(PercentInput.value(of: "300") == 300)
        #expect(PercentInput.value(of: "301") == nil)
        #expect(PercentInput.value(of: "") == nil)
        #expect(PercentInput.value(of: "abc") == nil)
    }

    @Test(
        "writes a stored rate the way the field shows it",
        arguments: [
            (0.0, "0"), (36.0, "36"), (2.5, "2,5"), (2.05, "2,05"), (24.75, "24,75"), (299.99, "299,99"),
        ])
    func text(rate: Double, shown: String) {
        #expect(PercentInput.text(for: rate) == shown)
    }

    @Test("a missing rate is an empty field")
    func missing() {
        #expect(PercentInput.text(for: nil) == "")
    }
}
