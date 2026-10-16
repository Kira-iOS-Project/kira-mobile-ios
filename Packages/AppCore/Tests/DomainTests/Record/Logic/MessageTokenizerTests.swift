import Testing

@testable import Domain

@Suite("MessageTokenizer")
struct MessageTokenizerTests {
    @Test("words, numbers with separators, hyphens and clause separators")
    func tokens() {
        let tokens = MessageTokenizer.tokens(of: "Kopi 1,5jt, kira-kira 25.000; parkir.")
        #expect(tokens.map(\.original) == ["Kopi", "1,5jt", ",", "kira-kira", "25.000", ";", "parkir"])
        #expect(tokens.map(\.kind) == [.word, .word, .separator, .word, .word, .separator, .word])
        #expect(tokens[0].text == "kopi")
        #expect(tokens[0].start == 0)
        #expect(tokens[0].end == 4)
    }

    @Test("a separator at either end and lone punctuation")
    func edges() {
        #expect(MessageTokenizer.tokens(of: ",kopi-").map(\.original) == [",", "kopi"])
        #expect(MessageTokenizer.tokens(of: "-").isEmpty)
        #expect(MessageTokenizer.tokens(of: "a.").map(\.original) == ["a"])
        #expect(MessageTokenizer.tokens(of: "2-3 a-1 a,b").map(\.original) == ["2-3", "a-1", "a", ",", "b"])
    }
}
