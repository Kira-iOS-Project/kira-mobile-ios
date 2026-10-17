import APIClient
import Domain
import Testing

@testable import Features

/** Tambah Tagihan's guards and the debt accounts Ini Cicilan Utang lists. */
@MainActor
@Suite("BillFormModel guards and debts")
struct BillFormModelGuardTests {
    private let paylater = Wallet(id: "debt-1", name: "Paylater A", type: .paylater, balance: 1_200_000)

    private func model(
        values: BillFormValues = BillFormValues(), editor: FakeBillEditorService = FakeBillEditorService(),
        wallets: FakeWalletService = FakeWalletService()
    ) -> BillFormModel {
        BillFormModel(mode: .create, values: values, editor: editor, wallets: wallets)
    }

    @Test("Tambah Tagihan cannot delete, and nothing is sent while incomplete")
    func guards() async {
        let editor = FakeBillEditorService()
        let form = model(editor: editor)
        await form.delete()
        await form.save()
        #expect(!form.deleted && !form.saved && (await editor.created).isEmpty && (await editor.deleted).isEmpty)
    }

    @Test("lists Dompet's debt accounts only; a linked account that is gone is unlinked")
    func debts() async {
        let wallets = FakeWalletService(
            wallets: [Wallet(id: "bca", name: "BCA", type: .bank, balance: 5_000_000)], debts: [paylater])
        var values = BillFormValues()
        values.debtId = "debt-9"
        let form = model(values: values, wallets: wallets)
        await form.loadDebts()
        #expect(form.debts.map(\.id) == ["debt-1"] && form.debtId == nil && form.isInstalment)
    }

    @Test("debt accounts that cannot load leave the list empty")
    func debtsFail() async {
        let wallets = FakeWalletService(debts: [paylater])
        await wallets.configure(failures: [.overview])
        let form = model(wallets: wallets)
        await form.loadDebts()
        #expect(form.debts.isEmpty)
    }
}
