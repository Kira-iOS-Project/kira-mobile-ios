import Testing

@testable import Domain

@Suite("AmountReader")
struct AmountReaderTests {
    /** The amount of a whole phrase, read from its first word. */
    private func amount(_ phrase: String) -> Int? {
        let words = MessageTokenizer.tokens(of: phrase).map(\.text)
        guard let (amount, next) = AmountReader.read(words, at: 0), next == words.count else { return nil }
        return amount
    }

    @Test(
        "digits with a unit, separators and Rp",
        arguments: [
            ("30rb", 30_000), ("30 rb", 30_000), ("20 ribu", 20_000), ("5 rebu", 5_000), ("30k", 30_000),
            ("1,5jt", 1_500_000), ("1.5jt", 1_500_000), ("1,5 juta", 1_500_000), ("2jt", 2_000_000),
            ("25.000", 25_000), ("25000", 25_000), ("Rp25.000", 25_000), ("Rp 25.000", 25_000),
            ("rp 25rb", 25_000), ("25.000,00", 25_000), ("1.500rb", 1_500_000), ("20rb-an", 20_000),
            ("2 miliar", 2_000_000_000), ("2 juta 500 ribu", 2_500_000), ("100", 100),
        ])
    func digits(phrase: String, expected: Int) {
        #expect(amount(phrase) == expected)
    }

    @Test(
        "number words",
        arguments: [
            ("sejuta", 1_000_000), ("seribu", 1_000), ("seratus ribu", 100_000), ("dua puluh ribu", 20_000),
            ("lima ribu", 5_000), ("lima belas ribu", 15_000), ("sebelas ribu", 11_000),
            ("dua ratus lima puluh ribu", 250_000), ("seratus dua puluh lima ribu", 125_000),
            ("satu setengah juta", 1_500_000), ("setengah juta", 500_000), ("sejuta setengah", 1_500_000),
            ("sepuluh ribu", 10_000), ("dua puluh lima", 25 * 1), ("seratus", 100),
        ])
    func words(phrase: String, expected: Int) {
        if expected < 100 {
            #expect(amount(phrase) == nil)
        } else {
            #expect(amount(phrase) == expected)
        }
    }

    @Test(
        "slang",
        arguments: [
            ("goceng", 5_000), ("gocap", 50_000), ("cepek", 100_000), ("ceban", 10_000), ("seceng", 1_000),
            ("noceng", 2_000), ("goban", 50_000), ("cepek ceng", 100_000), ("rp goceng", 5_000),
        ])
    func slang(phrase: String, expected: Int) {
        #expect(amount(phrase) == expected)
    }

    @Test(
        "a quantity or a word is not an amount", arguments: ["2", "5", "lima", "kopi", "ribu", "puluh", "belas", "rp"])
    func notAmounts(phrase: String) {
        let words = MessageTokenizer.tokens(of: phrase).map(\.text)
        #expect(AmountReader.read(words, at: 0) == nil)
    }

    @Test("an amount stops before what cannot continue it")
    func stops() throws {
        let words = ["15rb", "2", "gelas"]
        let read = try #require(AmountReader.read(words, at: 0))
        #expect(read.amount == 15_000)
        #expect(read.next == 1)
        #expect(AmountReader.read(["lima", "dua", "ribu"], at: 0) == nil)
        #expect(AmountReader.read(["1.5", "ribu", "juta"], at: 0)?.amount == 1_500)
        #expect(AmountReader.read(["goceng"], at: 1) == nil)
        #expect(AmountReader.read(["sejuta", "goceng"], at: 0)?.amount == 1_000_000)
    }

    @Test("a malformed number reads as nothing", arguments: ["1234.567", "25rbx", "12.34.5"])
    func malformed(token: String) {
        #expect(AmountWords.atoms(of: token).isEmpty)
    }
}
