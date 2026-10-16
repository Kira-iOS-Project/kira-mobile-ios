import Domain
import Testing

@testable import Features

@MainActor
@Suite("DebtFormModel")
struct DebtFormModelTests {
    @Test("a new form starts empty with the kind given, and groups amounts as typed")
    func newForm() {
        let model = DebtFormModel(kind: .onlineLoan)
        #expect(model.kind == .onlineLoan && model.name.isEmpty && model.editing == nil)
        model.remaining = "1150000"
        model.instalment = "230.0000"
        model.tenor = "14x5"
        #expect(model.remaining == "1.150.000")
        #expect(model.instalment == "2.300.000")
        #expect(model.tenor == "145")
    }

    @Test("a missing name or amount refuses to save until a field changes")
    func missing() {
        let model = DebtFormModel()
        model.name = "  "
        model.remaining = "1000"
        #expect(model.entry() == nil)
        #expect(model.showsMissing)
        model.instalment = "500"
        #expect(!model.showsMissing)
        #expect(model.entry() == nil)
        model.name = "Paylater C"
        model.tenor = "3"
        model.tenor = "3"
        #expect(model.entry()?.remainingTenorMonths == 3)
    }

    @Test("editing opens filled and keeps the debt's id")
    func editing() throws {
        let debt = DebtEntry(
            kind: .vehicle, name: "Cicilan Motor", remaining: 12_740_000, monthlyInstalment: 910_000,
            remainingTenorMonths: 14)
        let model = DebtFormModel(editing: debt)
        #expect(model.kind == .vehicle && model.name == "Cicilan Motor")
        #expect(model.remaining == "12.740.000" && model.instalment == "910.000" && model.tenor == "14")
        model.name = " Motor "
        let saved = try #require(model.entry())
        #expect(saved.id == debt.id && saved.name == "Motor" && saved.remaining == 12_740_000)
        #expect(
            DebtFormModel(editing: DebtEntry(kind: .paylater, name: "A", remaining: 1, monthlyInstalment: 1)).tenor
                .isEmpty)
    }
}
