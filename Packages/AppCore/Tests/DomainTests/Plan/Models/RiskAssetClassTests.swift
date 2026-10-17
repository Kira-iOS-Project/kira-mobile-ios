import Testing

@testable import Domain

@Suite("RiskAssetClass")
struct AssetClassTests {
    @Test("six classes, lowest risk first, as Pelajari Dulu lists them")
    func risk() {
        #expect(RiskAssetClass.allCases.map(\.risk) == [.low, .low, .low, .medium, .high, .veryHigh])
        #expect(AssetRisk.allCases.count == 4)
    }
}
