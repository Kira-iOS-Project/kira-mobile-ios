import Testing

@testable import Domain

@Suite("PayoffMethod")
struct PayoffMethodTests {
    @Test("each method is compared with the other one")
    func other() {
        #expect(PayoffMethod.snowball.other == .avalanche)
        #expect(PayoffMethod.avalanche.other == .snowball)
    }
}
