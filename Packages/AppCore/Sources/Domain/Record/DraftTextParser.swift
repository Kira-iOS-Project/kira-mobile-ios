/**
 The slang rules that turn a chat message into drafts on the device (CAT-01): "makan siang 25rb,
 grab ke kantor 18rb, kopi goceng" is three expenses. Each draft keeps the span of the message it
 was read from, so Riwayat can highlight it later.
 */

/** A transaction read from a message, before it has an id. */
package struct DraftCandidate: Equatable, Sendable {
    package var type: TransactionType
    package var name: String
    package var amount: Int
    package var category: TransactionCategory
    /** The UTF-16 offset of the first character read into this draft. */
    package var spanStart: Int
    /** The UTF-16 offset just after the last character read into this draft. */
    package var spanEnd: Int

    package init(
        type: TransactionType, name: String, amount: Int, category: TransactionCategory, spanStart: Int,
        spanEnd: Int
    ) {
        self.type = type
        self.name = name
        self.amount = amount
        self.category = category
        self.spanStart = spanStart
        self.spanEnd = spanEnd
    }
}

/** Reads drafts from a message with deterministic rules. */
package struct DraftTextParser: Sendable {
    /** Words that join two items like a comma: "parkir 5rb terus bakso 20rb". */
    static let conjunctions: Set<String> = ["dan", "terus", "trus", "trs", "lalu", "kemudian", "plus"]
    /** Words that open an item but are not its name: "tadi beli kopi 15rb" is "Kopi". */
    static let fillers: Set<String> = [
        "tadi", "td", "barusan", "habis", "abis", "beli", "bayar", "buat", "untuk", "aku", "saya", "gue",
        "gw", "rp", "itu", "juga", "dapat", "dapet", "terima", "nerima", "dikasih",
    ]

    /** The name of a draft whose message names only an amount, from the app's catalog. */
    private let fallbackName: String

    package init(fallbackName: String) {
        self.fallbackName = fallbackName
    }

    /** The drafts of `text`, in the order they were written. */
    package func parse(_ text: String) -> [DraftCandidate] {
        clauses(of: MessageTokenizer.tokens(of: text)).flatMap(drafts(in:))
    }

    /** The message split at separators and at joining words. */
    func clauses(of tokens: [MessageToken]) -> [[MessageToken]] {
        var clauses: [[MessageToken]] = [[]]
        for token in tokens {
            if token.kind == .separator || Self.conjunctions.contains(token.text) {
                clauses.append([])
            } else {
                clauses[clauses.count - 1].append(token)
            }
        }
        return clauses.filter { !$0.isEmpty }
    }

    /**
     The drafts of one clause. Each amount takes the words since the previous amount as its name
     ("kopi 15rb parkir 3rb"); an amount with no words before it takes the words after it, up to
     the next amount ("25rb makan siang").
     */
    func drafts(in clause: [MessageToken]) -> [DraftCandidate] {
        let words = clause.map(\.text)
        var drafts: [DraftCandidate] = []
        var nameStart = 0
        var index = 0
        while index < words.count {
            guard let (amount, next) = AmountReader.read(words, at: index) else {
                index += 1
                continue
            }
            var names = nameStart..<index
            if trimmed(names, words).isEmpty { names = next..<nextAmountStart(words, from: next) }
            let shown = trimmed(names, words)
            let first = shown.isEmpty ? index : min(index, shown.lowerBound)
            let last = max(next, shown.upperBound) - 1
            let guess = CategoryKeywords.guess(Array(words[names]))
            let name = shown.isEmpty ? fallbackName : NameCasing.titleCased(clause[shown].map(\.original))
            drafts.append(
                DraftCandidate(
                    type: guess.type, name: name, amount: amount, category: guess.category,
                    spanStart: clause[first].start, spanEnd: clause[last].end))
            nameStart = max(next, names.upperBound)
            index = nameStart
        }
        return drafts
    }

    /** `range` without the filler words that open it. */
    private func trimmed(_ range: Range<Int>, _ words: [String]) -> Range<Int> {
        let start = range.first { !Self.fillers.contains(words[$0]) } ?? range.upperBound
        return start..<range.upperBound
    }

    /** Where the next amount after `index` starts, or the clause's end. */
    private func nextAmountStart(_ words: [String], from index: Int) -> Int {
        (index..<words.count).first { AmountReader.read(words, at: $0) != nil } ?? words.count
    }
}
