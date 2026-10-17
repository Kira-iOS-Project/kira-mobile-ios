import Domain
import Testing

@testable import Features

@Suite("AssetModuleModel")
@MainActor
struct AssetModuleModelTests {
    @Test("a module opens on the drawn part 2", arguments: RiskAssetClass.allCases)
    func opensOnBasics(assetClass: RiskAssetClass) {
        let model = AssetModuleModel(assetClass: assetClass)
        #expect(model.assetClass == assetClass)
        #expect(model.part == .basics)
        #expect(!model.isLastPart)
    }

    @Test("Bagian Berikutnya walks to part 4, then the button finishes")
    func advance() {
        let model = AssetModuleModel(assetClass: .gold)
        #expect(model.advance())
        #expect(model.part == .holding)
        #expect(model.advance())
        #expect(model.part == .oversight)
        #expect(model.isLastPart)
        #expect(!model.advance())
        #expect(model.part == .oversight)
    }
}
