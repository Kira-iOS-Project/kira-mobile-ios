import Testing

@testable import Features

@Suite("AmountInput")
struct AmountInputTests {
    @Test("digits only, no leading zeros, grouped by thousands, at most twelve digits")
    func input() {
        #expect(AmountInput.digits(of: "Rp 18.000,-") == "18000")
        #expect(AmountInput.digits(of: "007") == "7")
        #expect(AmountInput.grouped("18000") == "18.000")
        #expect(AmountInput.grouped("1792000") == "1.792.000")
        #expect(AmountInput.grouped("500") == "500")
        #expect(AmountInput.grouped("") == "")
        #expect(AmountInput.digits(of: "1234567890123456") == "123456789012")
        #expect(AmountInput.value(of: "18.000") == 18_000)
        #expect(AmountInput.value(of: "") == 0)
        #expect(AmountInput.digits(of: "٣٤") == "")
    }
}
