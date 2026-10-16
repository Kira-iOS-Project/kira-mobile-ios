/**
 Writes a draft's name in Title Case as the design system asks, keeping Indonesian prepositions and
 conjunctions lower case after the first word: "grab ke kantor" is "Grab ke Kantor".
 */
package enum NameCasing {
    static let lowercaseWords: Set<String> = [
        "dari", "di", "ke", "dan", "untuk", "yang", "terhadap", "dengan", "pada", "atau",
    ]

    /**
     The words joined in Title Case. With `keepsAcronyms`, a word written in capitals of two to four
     letters stays as written (KRL, BPJS); receipts, which print everything in capitals, pass false.
     */
    package static func titleCased(_ words: [String], keepsAcronyms: Bool = true) -> String {
        words.enumerated().map { position, word in
            let lower = word.lowercased()
            if position > 0, lowercaseWords.contains(lower) { return lower }
            if keepsAcronyms, (2...4).contains(word.count), word == word.uppercased(), word.contains(where: \.isLetter) {
                return word
            }
            return lower.prefix(1).uppercased() + lower.dropFirst()
        }
        .joined(separator: " ")
    }
}
