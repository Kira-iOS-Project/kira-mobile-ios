import Domain
import Testing

@testable import Features

@MainActor
@Suite("DebtAnswersModel")
struct DebtAnswersModelTests {
    private func fill(_ model: DebtAnswersModel, name: String) {
        model.form.name = name
        model.form.remaining = "420000"
        model.form.instalment = "210000"
        model.saveForm()
    }

    @Test("a chip not chosen opens the sheet for its kind; saving adds the row and closes it")
    func addByChip() {
        let model = DebtAnswersModel()
        model.toggle(.paylater)
        #expect(model.isFormPresented && model.form.kind == .paylater)
        fill(model, name: "Paylater A")
        #expect(!model.isFormPresented)
        #expect(model.entries.map(\.name) == ["Paylater A"])
        #expect(model.isSelected(.paylater) && !model.isSelected(.vehicle))
    }

    @Test("a chosen chip removes its debts")
    func removeByChip() {
        let model = DebtAnswersModel()
        model.toggle(.paylater)
        fill(model, name: "Paylater A")
        model.toggle(.paylater)
        #expect(model.entries.isEmpty && !model.isFormPresented)
    }

    @Test("Tambah Utang Lain uses the last kind; a row reopens its debt and saving replaces it")
    func addAndEdit() throws {
        let model = DebtAnswersModel()
        model.add()
        #expect(model.form.kind == .paylater)
        fill(model, name: "Paylater A")
        model.add()
        #expect(model.form.kind == .paylater)
        model.isFormPresented = false
        let first = try #require(model.entries.first)
        model.edit(first)
        #expect(model.form.editing == first)
        model.form.name = "Paylater B"
        model.saveForm()
        #expect(model.entries.map(\.name) == ["Paylater B"])
    }

    @Test("a form with a missing field stays open")
    func missing() {
        let model = DebtAnswersModel()
        model.add()
        model.saveForm()
        #expect(model.isFormPresented && model.entries.isEmpty)
    }

    @Test("Tidak Ada clears the debts, can be un-chosen, and a new debt un-chooses it")
    func none() {
        let model = DebtAnswersModel()
        model.add()
        fill(model, name: "Paylater A")
        model.toggleNone()
        #expect(model.hasNoDebts && model.entries.isEmpty)
        model.toggleNone()
        #expect(!model.hasNoDebts)
        model.toggleNone()
        model.add()
        fill(model, name: "Paylater A")
        #expect(!model.hasNoDebts)
        model.clear()
        #expect(model.entries.isEmpty && !model.hasNoDebts)
    }
}
