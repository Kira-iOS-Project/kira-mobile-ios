/**
 What makes a PIN acceptable for the app lock (ONB-14, AKN-03): exactly six digits, and not one a
 person nearby would guess first. The PIN never leaves the device; only its salted hash is kept.
 */

/** The rules a new PIN must pass. */
package enum PinPolicy {
    /** The number of digits in a PIN. */
    package static let length = 6

    /** Why a PIN is refused, or nil when it is acceptable. */
    package static func problem(with pin: String) -> PinProblem? {
        let digits = pin.compactMap(\.wholeNumberValue)
        guard pin.count == length, digits.count == length, pin.allSatisfy(\.isASCII) else {
            return .notSixDigits
        }
        if isRepeating(digits) || isSequence(digits) { return .tooSimple }
        return nil
    }

    /** "111111", "121212", "123123": a pattern of one, two or three digits said again. */
    private static func isRepeating(_ digits: [Int]) -> Bool {
        (1...3).contains { period in
            digits.indices.dropFirst(period).allSatisfy { digits[$0] == digits[$0 - period] }
        }
    }

    /** "123456", "654321", "890123": each digit one more (or one less) than the one before. */
    private static func isSequence(_ digits: [Int]) -> Bool {
        [1, 9].contains { step in
            digits.indices.dropFirst().allSatisfy { digits[$0] == (digits[$0 - 1] + step) % 10 }
        }
    }
}

/** Why a new PIN is refused. */
package enum PinProblem: Error, Equatable, Sendable {
    /** Not exactly six digits. */
    case notSixDigits
    /** Repeated digits or a run such as 123456: the first PINs anyone tries. */
    case tooSimple
}
