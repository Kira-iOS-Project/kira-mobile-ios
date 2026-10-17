/**
 A crisis signal (PED-02): how strong it was and where it came from. It is all the server keeps of
 one (`POST /care/signals`): never the message, which stays on the device.
 */

/** How strong a crisis signal is. */
package enum CareSignalLevel: String, CaseIterable, Comparable, Sendable {
    /** Despair without words about ending one's life: "udah gak kuat lagi", "putus asa". */
    case concern
    /** Words about ending one's life or self-harm: "mending gak ada aja", "bunuh diri". */
    case danger

    /** `danger` ranks above `concern`. */
    package static func < (lhs: Self, rhs: Self) -> Bool {
        lhs == .concern && rhs == .danger
    }
}

/** Where a crisis signal came from. */
package enum CareSignalSource: String, CaseIterable, Sendable {
    /** A message written in the Catat chat. */
    case chat
    /** "Masih Berat" on a check-in greeting (PED-06). */
    case checkIn = "check_in"
}
