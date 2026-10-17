import Testing

@testable import Domain

@Suite("AssetClass")
struct AssetClassTests {
    @Test("six classes, lowest risk first, as Pelajari Dulu lists them")
    func risk() {
        #expect(AssetClass.allCases.map(\.risk) == [.low, .low, .low, .medium, .high, .veryHigh])
        #expect(AssetRisk.allCases.count == 4)
    }
}
