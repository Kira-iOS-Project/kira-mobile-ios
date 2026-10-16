/** PinRule refuses a PIN that is not six digits or is one digit repeated (ONB-14). */
import Testing

@testable import Domain

@Suite("PinRule")
struct PinRuleTests {
    @Test(
        "six digits, not all the same",
        arguments: [
            ("481923", true),
            ("112233", true),
            ("111111", false),
            ("000000", false),
            ("48192", false),
            ("4819230", false),
            ("48a923", false),
            ("", false),
        ])
    func isAcceptable(_ pin: String, _ expected: Bool) {
        #expect(PinRule.isAcceptable(pin) == expected)
    }
}
