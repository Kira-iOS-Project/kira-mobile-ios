import Foundation

/**
 Finds a crisis signal in a chat message with the reviewed phrase list (`CrisisPhrases`), on the
 device (PED-02). It reads each clause on its own, so a phrase never spans a comma or a full stop.
 */
package struct CrisisPhraseDetector: Sendable {
    private struct Phrase: Sendable {
        let words: [String]
        let endsClause: Bool
        let level: CareSignalLevel
    }

    private static let phrases: [Phrase] =
        CrisisPhrases.danger.map { phrase($0, level: .danger) } + CrisisPhrases.concern.map { phrase($0, level: .concern) }

    private static let cues = Set(CrisisPhrases.cues.map(CrisisText.word))

    /** The detector with the reviewed list. */
    package init() {}

    /** The strongest signal a listed phrase in `text` gives, or nil when none does. */
    package func level(of text: String) -> CareSignalLevel? {
        var strongest: CareSignalLevel?
        for clause in CrisisText.clauses(of: text) {
            for phrase in Self.phrases where Self.contains(clause, phrase) {
                strongest = max(strongest ?? phrase.level, phrase.level)
            }
        }
        return strongest
    }

    /** Whether `text` has a word of a heavy day (`CrisisPhrases.cues`), the debatable case. */
    package func hasCue(_ text: String) -> Bool {
        CrisisText.clauses(of: text).contains { clause in clause.contains { Self.cues.contains($0) } }
    }

    private static func phrase(_ text: String, level: CareSignalLevel) -> Phrase {
        let endsClause = text.hasSuffix(" $")
        let words = CrisisText.clauses(of: endsClause ? String(text.dropLast(2)) : text).flatMap(\.self)
        return Phrase(words: words, endsClause: endsClause, level: level)
    }

    private static func contains(_ clause: [String], _ phrase: Phrase) -> Bool {
        let count = phrase.words.count
        guard count > 0, clause.count >= count else { return false }
        let starts = phrase.endsClause ? [clause.count - count] : Array(0...(clause.count - count))
        return starts.contains { Array(clause[$0..<$0 + count]) == phrase.words }
    }
}

/** Reads a message and the phrases the same way: clauses of words in one spelling each. */
enum CrisisText {
    private static let clauseEnds: Set<Character> = [".", ",", ";", ":", "!", "?", "\n"]

    private static let spellings: [String: String] = {
        var map: [String: String] = [:]
        for (word, variants) in CrisisPhrases.spellings {
            for variant in variants { map[collapsed(variant)] = word }
        }
        return map
    }()

    /** The clauses of `text`, each its words in lower case, without accents, in one spelling. */
    static func clauses(of text: String) -> [[String]] {
        let folded = text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil).lowercased()
        return folded.split(whereSeparator: { clauseEnds.contains($0) }).map { clause in
            clause.split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map { word(String($0)) }
        }
        .filter { !$0.isEmpty }
    }

    /** `raw` with its repeated letters once ("capeeek" is "capek") and in its one spelling. */
    static func word(_ raw: String) -> String {
        let word = collapsed(raw.lowercased())
        return spellings[word] ?? word
    }

    private static func collapsed(_ word: String) -> String {
        var result = ""
        for character in word where !(character.isLetter && character == result.last) {
            result.append(character)
        }
        return result
    }
}
