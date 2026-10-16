import Domain

/**
 Apple's on-device model as a second reader of a chat message (PED-02), asked only where it
 supports Indonesian. The composition root gives it; without it the phrase list decides alone.
 */
package protocol CrisisRefining: Sendable {
    /** Whether the on-device model supports Indonesian (`supportsLocale(id_ID)`). */
    func supportsIndonesian() async -> Bool

    /** The model's reading of `text`, or nil when it is unavailable or failed. */
    func assess(_ text: String) async -> CrisisAssessment?
}

/** What the on-device model read in a message. */
package enum CrisisAssessment: Equatable, Sendable {
    /** No crisis signal. */
    case none
    /** A signal of the given level. */
    case signal(CareSignalLevel)
}
