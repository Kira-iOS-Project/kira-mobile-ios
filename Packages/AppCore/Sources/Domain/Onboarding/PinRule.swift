/**
 Kunci Kira (ONB-14): the app-lock PIN is six digits, kept as a hash on the device and never
 sent. A PIN of one digit repeated (111111) is refused: anyone would guess it first.
 */

/** What makes a PIN acceptable. */
package enum PinRule {
    /** Digits in a PIN. */
    package static let length = 6

    /** Whether `pin` is six digits and not one digit repeated. */
    package static func isAcceptable(_ pin: String) -> Bool {
        guard pin.count == length, DigitCode.digits(in: pin, length: length) == pin else { return false }
        return Set(pin).count > 1
    }
}
