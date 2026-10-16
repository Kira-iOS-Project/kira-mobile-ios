import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("NegotiationScriptModel")
struct NegotiationScriptModelTests {
    private let service = FakeCareToolsService()

    @MainActor final class Clipboard { var copied: [NegotiationScript.Fill] = [] }

    private func model(_ clipboard: Clipboard = Clipboard()) -> NegotiationScriptModel {
        NegotiationScriptModel(service: service, defaultReason: "penghasilan berkurang") { clipboard.copied.append($0) }
    }

    @Test("loads the name and the lenders, picks the first and fills its instalment")
    func load() async {
        let model = model()
        await model.load()
        #expect(model.phase.value?.map(\.name) == ["Pinjol A", "Paylater B"])
        #expect(model.script.name == "dinda" && model.lender?.name == "Pinjol A")
        #expect(model.instalmentText == "410.000" && model.script.currentInstalment == 410_000)
        await model.load()
        #expect(model.lender?.name == "Pinjol A")
    }

    @Test("picking a lender (09b) fills its instalment and closes the list")
    func select() async throws {
        let model = model()
        await model.load()
        model.isPickingLender = true
        model.select(try #require(model.phase.value?.last))
        #expect(model.lender?.name == "Paylater B" && model.script.currentInstalment == 230_000)
        #expect(!model.isPickingLender)
    }

    @Test("no debt recorded is empty, and the person still writes the amounts")
    func empty() async {
        await service.configure { $0.debtList = [] }
        let model = model()
        await model.load()
        guard case .empty = model.phase else { Issue.record("expected empty"); return }
        #expect(model.lender == nil)
        model.instalmentText = "230.000"
        model.affordableText = "Rp150.000"
        #expect(model.script.currentInstalment == 230_000 && model.affordableText == "150.000")
    }

    @Test("a refused or lost load shows the problem", arguments: [true, false])
    func failure(offline: Bool) async {
        let error: any Error = offline ? FakeCareToolsService.Offline() : FakeCareToolsService.problem
        await service.configure { $0.failing[.debts] = error }
        let model = model()
        await model.load()
        guard case .failed(let problem) = model.phase else { Issue.record("expected failed"); return }
        #expect(problem == (offline ? AppProblem() : FakeCareToolsService.problem))
    }

    @Test("a name that fails to load stays a gap; the lenders still load")
    func nameFailure() async {
        await service.configure { $0.failing[.name] = FakeCareToolsService.Offline() }
        let model = model()
        await model.load()
        #expect(model.phase.value?.count == 2 && model.script.name.isEmpty && model.shown.name == nil)
    }

    @Test("edits the reason and the contract number in their sheet; a blank reason keeps the old one")
    func editing() {
        let model = model()
        model.edit(.reason)
        #expect(model.editing == .reason && model.draft == "penghasilan berkurang")
        model.draft = "  "
        model.finishEditing()
        #expect(model.script.reason == "penghasilan berkurang" && model.editing == nil)
        model.edit(.reason)
        model.draft = "kena PHK"
        model.finishEditing()
        #expect(model.script.reason == "kena PHK")
        model.edit(.contract)
        model.draft = " PB-0098 4821 "
        model.finishEditing()
        #expect(model.script.contractNumber == "PB-0098 4821" && model.script.maskedContract == "••••4821")
        model.finishEditing()
        #expect(model.editing == nil)
    }

    @Test("Salin Naskah copies only a complete script, then shows Naskah Disalin (09c)")
    func copy() async {
        let clipboard = Clipboard()
        let model = model(clipboard)
        await model.load()
        model.copy()
        #expect(clipboard.copied.isEmpty && !model.showsCopied)
        model.affordableText = "150000"
        model.edit(.contract)
        model.draft = "PB-0098 4821"
        model.finishEditing()
        #expect(model.shown.contract == "••••4821")
        model.copy()
        #expect(clipboard.copied == [model.script.fill(for: .clipboard)] && model.showsCopied)
        #expect(clipboard.copied.first?.contract == "PB-0098 4821" && clipboard.copied.first?.name == "dinda")
        model.copiedClosed()
        #expect(!model.showsCopied)
    }
}
