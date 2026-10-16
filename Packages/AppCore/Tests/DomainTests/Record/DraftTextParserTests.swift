import Testing

@testable import Domain

@Suite("DraftTextParser")
struct DraftTextParserTests {
    private let parser = DraftTextParser(fallbackName: "Transaksi")

    /** The part of `text` a draft was read from. */
    private func spanned(_ text: String, _ draft: DraftCandidate) -> String {
        let units = Array(text.utf16)
        return String(decoding: units[draft.spanStart..<draft.spanEnd], as: UTF16.self)
    }

    @Test("the board's message is three expenses with their spans")
    func board() {
        let text = "makan siang 25rb, grab ke kantor 18rb, kopi goceng"
        let drafts = parser.parse(text)
        #expect(drafts.map(\.name) == ["Makan Siang", "Grab ke Kantor", "Kopi"])
        #expect(drafts.map(\.amount) == [25_000, 18_000, 5_000])
        #expect(drafts.map(\.category) == [.food, .transport, .coffee])
        #expect(drafts.allSatisfy { $0.type == .expense })
        #expect(drafts.map { spanned(text, $0) } == ["makan siang 25rb", "grab ke kantor 18rb", "kopi goceng"])
    }

    @Test("a spoken message with fillers and number words")
    func spoken() {
        let drafts = parser.parse("tadi parkir lima ribu, terus makan bakso dua puluh ribu")
        #expect(drafts.map(\.name) == ["Parkir", "Makan Bakso"])
        #expect(drafts.map(\.amount) == [5_000, 20_000])
        #expect(drafts.map(\.category) == [.transport, .food])
    }

    @Test("DictationTranscriber's own transcript of the spoken sample reads the same drafts")
    func dictated() {
        let drafts = parser.parse("Parkir 5000 terus bakso 20.000 rupiah")
        #expect(drafts.map(\.name) == ["Parkir", "Bakso"])
        #expect(drafts.map(\.amount) == [5_000, 20_000])
        #expect(drafts.map(\.category) == [.transport, .food])
    }

    @Test("items without commas, joined by words, or with the amount first")
    func layouts() {
        #expect(parser.parse("kopi 15rb parkir 3rb").map(\.name) == ["Kopi", "Parkir"])
        #expect(parser.parse("bensin 30rb dan pulsa 50rb").map(\.amount) == [30_000, 50_000])
        let first = parser.parse("25rb makan siang 18rb grab")
        #expect(first.map(\.name) == ["Makan Siang", "Grab"])
        #expect(first.map(\.amount) == [25_000, 18_000])
    }

    @Test("income from its words, a quantity kept in the name, acronyms kept")
    func incomeAndNames() {
        let salary = parser.parse("dapat gaji 7,5jt")
        #expect(salary.first?.type == .income)
        #expect(salary.first?.category == .salary)
        #expect(salary.first?.name == "Gaji")
        let gift = parser.parse("dikasih angpao 100rb")
        #expect(gift.first?.type == .income)
        #expect(gift.first?.category == .otherIncome)
        #expect(parser.parse("Beras 5 kg 72000").first?.name == "Beras 5 Kg")
        #expect(parser.parse("naik KRL 5rb").first?.name == "Naik KRL")
    }

    @Test("an amount alone takes the fallback name; text without amounts gives nothing")
    func edges() {
        let alone = parser.parse("50rb")
        #expect(alone.first?.name == "Transaksi")
        #expect(alone.first?.category == .otherExpense)
        #expect(parser.parse("halo kira").isEmpty)
        #expect(parser.parse("").isEmpty)
        #expect(parser.parse(", ,").isEmpty)
    }

    @Test("spans count UTF-16 units, as the API's indices do")
    func emojiSpan() throws {
        let text = "☕️ kopi 15rb"
        let draft = try #require(parser.parse(text).first)
        #expect(spanned(text, draft) == "kopi 15rb")
        #expect(draft.spanStart == 3)
    }
}
