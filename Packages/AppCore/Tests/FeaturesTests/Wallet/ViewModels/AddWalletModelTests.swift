import APIClient
import Domain
import Testing

@testable import Features

@Suite("AddWalletModel")
@MainActor
struct AddWalletModelTests {
    @Test("opens empty on E-Wallet; a saved wallet closes the sheet into Dompet Ditambahkan")
    func saves() async {
        let service = FakeWalletService()
        let model = AddWalletModel(service: service)
        model.name = "x"
        model.open()
        #expect(model.sheet.isOpen && model.type == .ewallet && model.name.isEmpty && model.amountText.isEmpty)
        model.name = "  Dompet Digital 2 "
        model.amountText = "1.250.000"
        await model.save()
        #expect(!model.sheet.isOpen && model.showsAdded && model.issues.isEmpty)
        #expect(await service.added == [WalletDraft(type: .ewallet, name: "Dompet Digital 2", amount: 1_250_000)])
    }

    @Test("a missing name, or a debt account without its debt, stays inline and sends nothing")
    func validation() async {
        let service = FakeWalletService()
        let model = AddWalletModel(service: service)
        model.open()
        model.select(.paylater)
        await model.save()
        #expect(model.issues == [.missingName, .missingDebt] && model.sheet.isOpen)
        model.select(.cash)
        #expect(model.issues == [.missingName])
        model.name = "Tunai"
        await model.save()
        #expect(model.issues.isEmpty && model.showsAdded)
        #expect(await service.added == [WalletDraft(type: .cash, name: "Tunai", amount: 0)])
    }

    @Test("a failed save closes into the failure dialog; Coba Lagi sends what was typed")
    func failure() async {
        let service = FakeWalletService()
        await service.configure(failures: [.add])
        let model = AddWalletModel(service: service)
        model.open()
        model.select(.creditCard)
        model.name = "Kartu A"
        model.amountText = "3000000"
        await model.save()
        #expect(!model.sheet.isOpen && model.sheet.failure?.code == "ROUTE_NOT_FOUND" && !model.showsAdded)
        await service.configure()
        model.sheet.open()
        await model.save()
        #expect(model.showsAdded && model.name == "Kartu A")
        #expect(await service.added.map(\.amount) == [3_000_000, 3_000_000])
    }
}
