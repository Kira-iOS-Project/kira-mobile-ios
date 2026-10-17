import Testing

@testable import Domain

@Suite("AssetModulePart")
struct AssetModulePartTests {
    @Test("the drawn parts are 2, 3 and 4 of 4")
    func numbers() {
        #expect(AssetModulePart.allCases.map(\.number) == [2, 3, 4])
        #expect(AssetModulePart.total == 4)
    }

    @Test("each part leads to the next, the last to none")
    func next() {
        #expect(AssetModulePart.basics.next == .holding)
        #expect(AssetModulePart.holding.next == .oversight)
        #expect(AssetModulePart.oversight.next == nil)
    }
}
