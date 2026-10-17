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
        let created = await editor.created
        let deleted = await editor.deleted
        #expect(!form.deleted && !form.saved && created.isEmpty && deleted.isEmpty)
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

    @Test("Ubah Tagihan opens with the bill's fields; a list-only category opens on Lainnya")
    func fromBill() {
        let day = CalendarDay(year: 2026, month: 10, day: 22)
        let bill = Bill(
            id: "b-1", name: "Internet Rumah", kind: .bill, category: "entertainment", amount: 350_000,
            repeats: .yearly, dueOn: day, dueDay: 22, nextDueOn: day, debtId: "debt-1")
        let values = BillFormValues(bill: bill)
        #expect(values == BillFormValues(
            name: "Internet Rumah", amount: 350_000, category: .entertainment, repeats: .yearly, dueOn: day,
            debtId: "debt-1"))
        let household = Bill(
            id: "b-2", name: "Air", kind: .bill, category: "household", amount: 90_000, dueOn: day, dueDay: 22,
            nextDueOn: day)
        #expect(BillFormValues(bill: household).category == .other)
    }
}
