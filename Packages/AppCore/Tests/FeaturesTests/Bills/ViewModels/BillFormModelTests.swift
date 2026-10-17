import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Tambah Tagihan and Ubah Tagihan on TambahTagihan's Internet Rumah, Rp350.000 on the 22nd. */
@MainActor
@Suite("BillFormModel")
struct BillFormModelTests {
    private let day = CalendarDay(year: 2026, month: 10, day: 22)
    private let paylater = Wallet(id: "debt-1", name: "Paylater A", type: .paylater, balance: 1_200_000)

    private func model(
        _ mode: BillFormModel.Mode = .create, values: BillFormValues = BillFormValues(),
        editor: FakeBillEditorService = FakeBillEditorService(), wallets: FakeWalletService = FakeWalletService()
    ) -> BillFormModel {
        BillFormModel(mode: mode, values: values, editor: editor, wallets: wallets)
    }

    private func filled(_ model: BillFormModel) -> BillFormModel {
        model.name = "  Internet Rumah "
        model.amount = "350.000"
        model.dueOn = day
        return model
    }

    @Test("opens empty, monthly, on Tagihan, not a cicilan, with Simpan off")
    func empty() {
        let form = model()
        #expect(form.name.isEmpty && form.amount.isEmpty && form.dueOn == nil)
        #expect(form.category == .bills && form.repeats == .monthly && !form.isInstalment)
        #expect(!form.canSave && form.draft == nil)
    }

    @Test("needs a name of 1 to 60 characters, an amount above zero and a date")
    func required() {
        let form = filled(model())
        #expect(form.canSave)
        form.name = "   "
        #expect(!form.canSave)
        form.name = String(repeating: "a", count: 61)
        #expect(!form.canSave)
        form.name = String(repeating: "a", count: 60)
        #expect(form.canSave)
        form.amount = "0"
        #expect(!form.canSave)
        form.amount = ""
        #expect(!form.canSave)
        form.amount = "350.000"
        form.dueOn = nil
        #expect(!form.canSave)
    }

    @Test("a cicilan needs its debt account; switched off, none is sent")
    func instalment() {
        let form = filled(model())
        form.isInstalment = true
        #expect(!form.canSave)
        form.debtId = "debt-1"
        #expect(form.draft?.debtId == "debt-1")
        form.isInstalment = false
        #expect(form.canSave && form.draft?.debtId == nil)
    }

    @Test("Simpan Tagihan sends the trimmed draft once and ends saved")
    func create() async {
        let editor = FakeBillEditorService()
        let form = filled(model(editor: editor))
        form.category = .other
        form.repeats = .yearly
        await form.save()
        #expect(form.saved && form.failure == nil && !form.isWorking)
        let created = await editor.created
        #expect(
            created == [
                BillDraft(name: "Internet Rumah", amount: 350_000, category: .other, repeats: .yearly, dueOn: day)
            ])
        #expect(BillCategory.other.rawValue == "other_expense")
    }

    @Test("a failed save keeps the form and the problem; Coba Lagi sends it again")
    func failedSave() async {
        let editor = FakeBillEditorService()
        await editor.configure { $0.failing[.create] = [URLError(.notConnectedToInternet)] }
        let form = filled(model(editor: editor))
        await form.save()
        #expect(!form.saved && form.failure?.isConnectionLoss == true && form.name == "  Internet Rumah ")
        await form.retry()
        let created = await editor.created
        #expect(form.saved && form.failure == nil && created.count == 1)
    }

    @Test("Ubah Tagihan opens with the bill, Simpan Perubahan updates it by id")
    func update() async {
        let editor = FakeBillEditorService()
        let values = BillFormValues(
            name: "Internet Rumah", amount: 350_000, category: .bills, repeats: .monthly, dueOn: day,
            debtId: "debt-1")
        let form = model(.edit(id: "b-1"), values: values, editor: editor)
        #expect(form.amount == "350000" && form.isInstalment && form.debtId == "debt-1" && form.canSave)
        form.amount = "375.000"
        await form.save()
        let updated = await editor.updated
        #expect(form.saved && updated["b-1"]?.amount == 375_000)
    }

    @Test("a gone bill on save is BILL_NOT_FOUND; a gone debt account is BILL_DEBT_NOT_FOUND")
    func refusals() async {
        let editor = FakeBillEditorService()
        await editor.configure {
            $0.failing[.update] = [AppProblem(code: "BILL_NOT_FOUND"), AppProblem(code: "BILL_DEBT_NOT_FOUND")]
        }
        let form = filled(model(.edit(id: "b-1"), editor: editor))
        await form.save()
        #expect(form.failure?.knownCode == .billNotFound)
        await form.retry()
        #expect(form.failure?.knownCode == .billDebtNotFound && !form.saved)
    }

    @Test("Hapus deletes the bill by id; a failure is kept and Coba Lagi deletes again")
    func delete() async {
        let editor = FakeBillEditorService()
        await editor.configure { $0.failing[.delete] = [URLError(.timedOut)] }
        let form = filled(model(.edit(id: "b-1"), editor: editor))
        await form.delete()
        #expect(!form.deleted && form.failure != nil)
        await form.retry()
        let deleted = await editor.deleted
        #expect(form.deleted && form.failure == nil && deleted == ["b-1"])
    }
}
