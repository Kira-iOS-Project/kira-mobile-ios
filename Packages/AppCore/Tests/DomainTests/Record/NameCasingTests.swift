import Testing

@testable import Domain

@Suite("NameCasing")
struct NameCasingTests {
    @Test("Title Case with lower-case prepositions after the first word")
    func titleCase() {
        #expect(NameCasing.titleCased(["grab", "ke", "kantor"]) == "Grab ke Kantor")
        #expect(NameCasing.titleCased(["ke", "pasar"]) == "Ke Pasar")
        #expect(NameCasing.titleCased(["BPJS", "kesehatan"]) == "BPJS Kesehatan")
        #expect(NameCasing.titleCased(["MINYAK", "GORENG", "2", "L"], keepsAcronyms: false) == "Minyak Goreng 2 L")
        #expect(NameCasing.titleCased(["KG", "25"]) == "KG 25")
        #expect(NameCasing.titleCased(["12"]) == "12")
    }
}
