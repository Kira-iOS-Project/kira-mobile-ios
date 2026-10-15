// A code typed or pasted as digits: the app lock's PIN or the one-time code sent by email. Whatever
// arrives in the field (a pasted "Kode kamu: 381 449", a keyboard's suggestion), only its digits
// count, up to the code's length, so a pasted code fills every box at once.

/// The digits of a PIN or a one-time code.
package enum DigitCode {
    /// The ASCII digits of `input`, in order, without anything around or between them, and at most
    /// `length` of them: "Kode: 381 449" becomes "381449".
    package static func digits(in input: String, length: Int) -> String {
        String(input.filter { ("0"..."9").contains($0) }.prefix(max(length, 0)))
    }
}
