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

/**
 Decides whether a chat message is a crisis signal, on the device. The reviewed phrase list
 decides first. The model is asked only for a message the list did not find danger in that has a
 listed phrase or a word of a heavy day (the debatable case), only where it supports Indonesian,
 and only while Kira AI is on. It may raise the level, never lower the list's: a missed signal
 costs more than a false one.
 */
package struct CrisisDetector: Sendable {
    private let phrases = CrisisPhraseDetector()
    private let refiner: (any CrisisRefining)?

    /** The detector, with the on-device model when there is one. */
    package init(refiner: (any CrisisRefining)?) {
        self.refiner = refiner
    }

    /** The signal in `text`, or nil; `allowsModel` is false while Kira AI is off. */
    package func level(of text: String, allowsModel: Bool) async -> CareSignalLevel? {
        let listed = phrases.level(of: text)
        guard listed != .danger, allowsModel, let refiner, listed != nil || phrases.hasCue(text),
            await refiner.supportsIndonesian(), case .signal(let level) = await refiner.assess(text)
        else { return listed }
        return max(listed ?? level, level)
    }
}
