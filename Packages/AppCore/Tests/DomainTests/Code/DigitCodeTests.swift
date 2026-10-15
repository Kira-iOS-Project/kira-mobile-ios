// DigitCode keeps a code's digits, up to its length, whatever is typed or pasted around them.
import Testing

@testable import Domain

@Suite("DigitCode keeps the digits of a typed or pasted code")
struct DigitCodeTests {
    @Test(
        "only ASCII digits count, in order, up to the length",
        arguments: [
            ("", 6, ""),
            ("3814", 6, "3814"),
            ("381449", 6, "381449"),
            ("3814490", 6, "381449"),
            ("Kode kamu: 381 449", 6, "381449"),
            ("38-14-49", 6, "381449"),
            ("١٢٣456", 6, "456"),
            ("abc", 6, ""),
            ("381449", 4, "3814"),
            ("381449", 0, ""),
            ("381449", -1, ""),
        ])
    func digits(_ input: String, _ length: Int, _ expected: String) {
        #expect(DigitCode.digits(in: input, length: length) == expected)
    }
}
