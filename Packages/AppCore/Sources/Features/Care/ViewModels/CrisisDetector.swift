import Domain

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
