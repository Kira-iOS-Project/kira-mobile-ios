/** What the PIN sheet asks for. */
package enum PinPrompt: Equatable, Sendable {
    /** The current PIN, to turn the lock off. */
    case verifyToDisable
    /** A new PIN, to turn the lock on. */
    case create
    /** The current PIN, before choosing a new one. */
    case verifyToChange
    /** The new PIN that replaces the current one. */
    case createReplacement
}

/** Why the PIN sheet did not go on. */
package enum PinError: Equatable, Sendable {
    /** The PIN typed is not the one that locks Kira. */
    case wrong
    /** The device could not keep the new PIN. */
    case notSaved
}
