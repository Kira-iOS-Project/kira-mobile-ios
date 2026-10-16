/**
 Splits a chat message into words and separators, each with its place in the message counted in
 UTF-16 units, the unit the API's `spanStart` and `spanEnd` use (JavaScript string indices).
 */

/** A word or a separator of a message. */
package struct MessageToken: Equatable, Sendable {
    /** Whether the token is a word (letters, digits or both) or ends a clause. */
    package enum Kind: Equatable, Sendable {
        /** Letters, digits or both. */
        case word
        /** A character that ends a clause. */
        case separator
    }

    /** The token as written. */
    package let original: String
    /** The token in lower case, as the parsers compare it. */
    package let text: String
    /** The first UTF-16 offset of the token in the message. */
    package let start: Int
    /** The UTF-16 offset just after the token. */
    package let end: Int
    /** A word or a separator. */
    package let kind: Kind

    /** A token of the message. */
    package init(original: String, start: Int, end: Int, kind: Kind) {
        self.original = original
        self.text = original.lowercased()
        self.start = start
        self.end = end
        self.kind = kind
    }
}

/** Turns a message into tokens. */
package enum MessageTokenizer {
    /** Characters that end a clause: "kopi 15rb, parkir 3rb". */
    static let separators: Set<Character> = [",", ";", "\n", "+", "&", "!", "?"]

    /**
     The tokens of `text`. A dot or a comma between two digits belongs to the number ("1,5jt",
     "25.000"), a hyphen between two letters or digits to the word ("kira-kira"); any other
     character that is not a letter or a digit splits words, and the separators also end a clause.
     */
    package static func tokens(of text: String) -> [MessageToken] {
        let characters = Array(text)
        var tokens: [MessageToken] = []
        var word = ""
        var wordStart = 0
        var offset = 0
        for (index, character) in characters.enumerated() {
            let width = character.utf16.count
            if belongsToWord(characters, at: index) {
                if word.isEmpty { wordStart = offset }
                word.append(character)
            } else {
                if !word.isEmpty {
                    tokens.append(MessageToken(original: word, start: wordStart, end: offset, kind: .word))
                    word = ""
                }
                if separators.contains(character) {
                    tokens.append(
                        MessageToken(original: String(character), start: offset, end: offset + width, kind: .separator))
                }
            }
            offset += width
        }
        if !word.isEmpty {
            tokens.append(MessageToken(original: word, start: wordStart, end: offset, kind: .word))
        }
        return tokens
    }

    /** Whether the character at `index` is part of a word. */
    private static func belongsToWord(_ characters: [Character], at index: Int) -> Bool {
        let character = characters[index]
        if character.isLetter || character.isNumber { return true }
        guard index > 0, index + 1 < characters.count else { return false }
        let before = characters[index - 1]
        let after = characters[index + 1]
        switch character {
        case ".", ",": return before.isNumber && after.isNumber
        case "-": return (before.isLetter || before.isNumber) && (after.isLetter || after.isNumber)
        default: return false
        }
    }
}
