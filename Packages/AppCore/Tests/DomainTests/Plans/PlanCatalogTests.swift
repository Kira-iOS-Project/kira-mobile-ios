import Testing

@testable import Domain

@Suite("PlanCatalog")
struct PlanCatalogTests {
    @Test("finds a plan's terms, nil when the API left it out")
    func terms() {
        let plus = PlanTerms(
            id: .plus, monthlyPrice: 29_000, yearlyPrice: 290_000, aiMessages: 300, receipts: 150,
            voiceSeconds: 10_800, voiceAndImport: true)
        let catalog = PlanCatalog(plans: [plus], current: .init(plan: .plus, period: .yearly))
        #expect(catalog.terms(for: .plus) == plus)
        #expect(catalog.terms(for: .young) == nil)
        #expect(catalog.current.period == .yearly)
    }
}
