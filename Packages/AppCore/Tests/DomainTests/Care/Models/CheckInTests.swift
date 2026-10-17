import Testing

@testable import Domain

@Suite("CheckIn")
struct CheckInTests {
    @Test("the delays are the board's 24, 48 and 72 hours")
    func hours() {
        #expect(CheckInDelay.allCases.map(\.hours) == [24, 48, 72])
    }

    @Test("a check-in keeps its id")
    func fields() {
        #expect(CheckIn(id: "c1").id == "c1")
    }
}
