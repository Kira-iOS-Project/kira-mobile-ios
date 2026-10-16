import Testing

@testable import Domain

@Suite("PinPolicy")
struct PinPolicyTests {
    @Test("accepts six digits without a pattern", arguments: ["381449", "902716", "100200", "135790"])
    func accepts(pin: String) {
        #expect(PinPolicy.problem(with: pin) == nil)
    }

    @Test("refuses anything but six ASCII digits", arguments: ["", "12345", "1234567", "12a456", "38144٩", " 38144"])
    func refusesShape(pin: String) {
        #expect(PinPolicy.problem(with: pin) == .notSixDigits)
    }

    @Test(
        "refuses repeated digits and runs",
        arguments: ["111111", "000000", "121212", "123123", "123456", "654321", "890123", "210987"])
    func refusesSimple(pin: String) {
        #expect(PinPolicy.problem(with: pin) == .tooSimple)
    }
}
