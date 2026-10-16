import Testing

@testable import Domain

@Suite("CrisisPhraseDetector")
struct CrisisPhraseDetectorTests {
    private let detector = CrisisPhraseDetector()

    @Test(
        "words about ending one's life or self-harm are danger, in any spelling",
        arguments: [
            "tagihan numpuk semua, capek banget. kayaknya mending gak ada aja", "Aku mau bunuh diri.",
            "pengeeen matiii ajaaa", "gw udh ga kuat hidup", "rasanya pgn bundir", "MENDINGAN AKU GA ADA",
            "self-harm lagi semalam", "capek hidup kayak gini", "aku gak mau hidup", "kadang kepikiran akhiri hidupku",
            "aku gak mau bunuh diri kok", "i want to die", "udah gak pengen hidup lagi",
            "mau mati aja", "ingin mengakhiri hidup",
        ])
    func danger(message: String) {
        #expect(detector.level(of: message) == .danger)
    }

    @Test(
        "despair without words about ending one's life is concern",
        arguments: [
            "Putus asa banget sama utang", "aku udah gak kuat.", "gak tau harus gimana lagi", "pengen nyerah aja",
            "utang 5jt, aku udah ga sanggup", "hidupku hancur gara-gara pinjol", "tiap malam nangis terus",
            "aku gak kuat lagi aku", "udah gak kuat banget", "aku stres berat",
        ])
    func concern(message: String) {
        #expect(detector.level(of: message) == .concern)
    }

    @Test(
        "ordinary spending, and a heavy day alone, give no signal",
        arguments: [
            "capek banget hari ini beli kopi 25rb", "makan siang 25rb, grab ke kantor 18rb, kopi goceng",
            "hp mau mati, beli charger 50rb", "udah gak kuat bayar cicilan 2jt", "lampu mati, beli token 100rb",
            "mati lampu", "pusing tagihan listrik 300rb", "beli racun tikus 15rb", "lelah lembur, gofood 40rb",
            "gak mau hidup boros lagi", "asuransi jiwa 500rb", "aku aman", "", "   ",
            "hp hancur banget, servis 300rb", "stres berat kerjaan, kopi 30rb", "udah gak kuat banget bayar cicilan",
        ])
    func none(message: String) {
        #expect(detector.level(of: message) == nil)
    }

    @Test("the strongest phrase wins when a message has both levels")
    func strongestWins() {
        #expect(detector.level(of: "putus asa. rasanya pengen mati") == .danger)
    }

    @Test("a phrase never spans two clauses")
    func clauses() {
        #expect(detector.level(of: "pengen, mati lampu") == nil)
        #expect(detector.level(of: "udah gak kuat, bayar cicilan") == .concern)
    }

    @Test(
        "the debatable case: a word of a heavy day without a phrase",
        arguments: [
            ("capek banget hari ini beli kopi 25rb", true), ("sedih bgt", true), ("bensin 30rb", false),
            ("", false),
        ])
    func cues(message: String, hasCue: Bool) {
        #expect(detector.hasCue(message) == hasCue)
    }

    @Test("slang spellings and repeated letters read as one word")
    func spelling() {
        #expect(CrisisText.word("Nggaaak") == "gak")
        #expect(CrisisText.word("capeeek") == "capek")
        #expect(CrisisText.word("25rb") == "25rb")
        #expect(CrisisText.clauses(of: "Gw   sdh, cápek!") == [["aku", "udah"], ["capek"]])
    }

    @Test("danger ranks above concern")
    func order() {
        #expect(CareSignalLevel.concern < .danger)
        #expect(!(CareSignalLevel.danger < .concern))
        #expect(CareSignalSource.checkIn.rawValue == "check_in")
    }
}
