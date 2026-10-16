import Testing

@testable import Domain

@Suite("NumberText")
struct NumberTextTests {
    @Test(
        "Indonesian and English separators",
        arguments: [
            ("25000", 25_000.0), ("25.000", 25_000), ("25,000", 25_000), ("25.000,00", 25_000),
            ("2.500.000", 2_500_000), ("1,5", 1.5), ("1.5", 1.5), ("25,00", 25),
        ])
    func values(text: String, expected: Double) {
        #expect(NumberText.value(of: text) == expected)
    }

    @Test("not numbers", arguments: ["", "abc", "1..2", "1.2345.678", "1234.567", ".5", "5."])
    func invalid(text: String) {
        #expect(NumberText.value(of: text) == nil)
    }
}
