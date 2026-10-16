import Testing

@testable import Domain

@Suite("DisplayName")
struct DisplayNameTests {
    @Test("takes the leading letters of the local part, capitalised")
    func leadingLetters() {
        #expect(DisplayName.from(email: "dinda@email.com") == "Dinda")
        #expect(DisplayName.from(email: "DINDA.r93@email.com") == "Dinda")
        #expect(DisplayName.from(email: "budi") == "Budi")
    }

    @Test("is nil when the local part starts with no letter")
    func noLetters() {
        #expect(DisplayName.from(email: "93dinda@email.com") == nil)
        #expect(DisplayName.from(email: "@email.com") == nil)
        #expect(DisplayName.from(email: "") == nil)
    }
}
