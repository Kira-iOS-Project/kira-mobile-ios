import APIClient
import Domain
import Testing

@testable import Features

@Suite("WalletCreateModel")
@MainActor
struct WalletCreateModelTests {
    @Test("requires a name and a numeric amount before posting")
    func validation() async {
        let service = FakeWalletService()
        let model = WalletCreateModel(service: service)
        #expect(model.canSave == false)
        await model.save()
        #expect(model.showsFieldErrors)
        #expect(model.phase.value == nil)
        #expect(await service.createdInput() == nil)
        model.name = "Tunai"
        model.amountText = "Rp 12.500"
        #expect(model.canSave)
    }

    @Test("creates the selected type with a trimmed unique name and whole rupiah")
    func success() async {
        let service = FakeWalletService()
        let model = WalletCreateModel(service: service)
        model.type = .paylater
        model.name = "  Paylater A  "
        model.amountText = "420.000"
        await model.save()
        let input = await service.createdInput()
        #expect(input == WalletCreateInput(type: .paylater, name: "Paylater A", balance: 420_000))
        #expect(model.phase.value?.name == "Paylater A")
    }

    @Test("keeps the draft intact on server failure and can reset it for a new sheet")
    func failureAndReset() async {
        let service = FakeWalletService()
        await service.configure(failures: [.create])
        let model = WalletCreateModel(service: service)
        model.type = .creditCard
        model.name = "Card"
        model.amountText = "30000"
        await model.save()
        guard case .failed(let problem) = model.phase else {
            Issue.record("Expected failed create")
            return
        }
        #expect(problem.code == "ROUTE_NOT_FOUND")
        #expect(model.name == "Card")
        #expect(model.amountText == "30000")
        #expect(model.type == .creditCard)
        #expect(model.canSave)
        model.resetDraft()
        #expect(model.phase.value == nil)
        #expect(model.name.isEmpty)
        #expect(model.amountText.isEmpty)
        #expect(model.type == .bank)
        #expect(model.showsFieldErrors == false)
        #expect(model.isSaving == false)
    }

    @Test("reports an in-flight save and prevents a duplicate submission")
    func inFlight() async {
        let service = FakeWalletService()
        await service.configure(delay: .milliseconds(40))
        let model = WalletCreateModel(service: service)
        model.name = "Bank"
        model.amountText = "1"
        let saving = Task { await model.save() }
        try? await Task.sleep(for: .milliseconds(5))
        #expect(model.isSaving)
        #expect(model.canSave == false)
        await saving.value
        #expect(model.isSaving == false)
    }
}
