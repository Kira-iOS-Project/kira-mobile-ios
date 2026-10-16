/** EmailAddress tidies an email and checks its shape before a code is asked for (ONB-06). */
import Testing

@testable import Domain

@Suite("EmailAddress checks the shape of a typed email")
struct EmailAddressTests {
    @Test("spaces around go and letters turn lower case")
    func normalized() {
        #expect(EmailAddress.normalized("  Dinda@Email.COM \n") == "dinda@email.com")
    }

    @Test(
        "an address needs one @, a local part and a dotted domain",
        arguments: [
            ("dinda@email.com", true),
            (" Dinda@Email.com ", true),
            ("d.a+kira@mail.co.id", true),
            ("", false),
            ("dinda", false),
            ("dinda@", false),
            ("@email.com", false),
            ("dinda@email", false),
            ("dinda@@email.com", false),
            ("din da@email.com", false),
            ("dinda@.email.com", false),
            ("dinda@email.com.", false),
            ("dinda@email..com", false),
        ])
    func isValid(_ input: String, _ expected: Bool) {
        #expect(EmailAddress.isValid(input) == expected)
    }
}
