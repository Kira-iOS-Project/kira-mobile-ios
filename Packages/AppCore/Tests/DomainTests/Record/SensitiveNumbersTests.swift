import Testing

@testable import Domain

@Suite("SensitiveNumbers")
struct SensitiveNumbersTests {
    @Test("long digit runs keep only their last four digits; amounts and short numbers stay")
    func masked() {
        #expect(SensitiveNumbers.masked("Debit 4111 1111 1111 1234") == "Debit ••••1234")
        #expect(SensitiveNumbers.masked("Rek 1234567890") == "Rek ••••7890")
        #expect(SensitiveNumbers.masked("Total 125.500,00") == "Total 125.500,00")
        #expect(SensitiveNumbers.masked("Kasir 0812-345") == "Kasir 0812-345")
    }
}
