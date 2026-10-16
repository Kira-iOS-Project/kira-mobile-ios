import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("TransactionDetailModel")
struct TransactionDetailModelTests {
    private let service = FakeHistoryService()

    /** A model on the sample transaction, loaded, counting its change notices. */
    private func loaded(_ changes: Changes = Changes()) async -> TransactionDetailModel {
        let model = TransactionDetailModel(id: "grab", service: service) { changes.count += 1 }
        await model.load()
        return model
    }

    @MainActor final class Changes { var count = 0 }

    @Test("loads the transaction with its source message, or the API's problem")
    func load() async {
        let model = await loaded()
        #expect(model.phase.value == Sample.detail)
        await service.configure { $0.failing = [.transaction] }
        let failing = TransactionDetailModel(id: "grab", service: service)
        failing.startEditing()
        #expect(failing.editor == nil)
        await failing.load()
        guard case .failed = failing.phase else {
            Issue.record("expected failed")
            return
        }
    }

    @Test("saves only what changed, shows Perubahan Tersimpan, then closes the sheet")
    func save() async throws {
        let changes = Changes()
        let model = await loaded(changes)
        model.startEditing()
        model.editor?.name = "Grab ke Kantor Pagi"
        await model.save()
        #expect(await service.changes == [TransactionChange(name: "Grab ke Kantor Pagi")])
        #expect(model.phase.value?.transaction.name == "Grab ke Kantor Pagi")
        #expect(model.editResult == .saved && model.shownEditResult == .saved)
        #expect(changes.count == 1)
        model.editResultClosed()
        #expect(model.editor == nil && model.editResult == nil)
    }

    @Test("saves without anyone to notify")
    func saveWithoutListener() async {
        let model = TransactionDetailModel(id: "grab", service: service)
        await model.load()
        model.startEditing()
        model.editor?.category = .food
        await model.save()
        #expect(model.editResult == .saved)
    }

    @Test("closes the sheet without a call when nothing changed, and refuses an invalid form")
    func unchanged() async {
        let model = await loaded()
        await model.save()
        model.startEditing()
        model.editor?.amountText = ""
        await model.save()
        #expect(model.editor != nil)
        model.editor?.amountText = "18000"
        await model.save()
        #expect(model.editor == nil)
        #expect(await service.changes.isEmpty)
    }

    @Test("keeps the fields after a failed save, and Coba Lagi sends them again")
    func saveFailure() async {
        await service.configure { $0.failing = [.update] }
        let model = await loaded()
        model.startEditing()
        model.editor?.amountText = "20000"
        await model.save()
        #expect(model.editResult == .failed)
        model.editResultClosed()
        #expect(model.editor?.amountText == "20.000")
        await service.configure { $0.failing = [] }
        await model.save()
        #expect(model.editResult == .saved)
        #expect(await service.changes.count == 2)
    }

    @Test("asks before deleting, deletes, and leaves for Riwayat once the dialog closes")
    func delete() async {
        let changes = Changes()
        let model = await loaded(changes)
        model.requestDelete()
        #expect(model.dialog == .confirmDelete)
        model.dialogClosed()
        #expect(model.dialog == nil && !model.isClosed)
        model.requestDelete()
        await model.confirmDelete()
        #expect(model.dialog == .deleted && model.shownDialog == .deleted)
        #expect(await service.deleted == ["grab"])
        #expect(changes.count == 1)
        model.dialogClosed()
        #expect(model.isClosed)
    }

    @Test("a failed delete offers Coba Lagi, and work already running is not started twice")
    func deleteFailure() async {
        await service.configure { $0.failing = [.delete, .update] }
        let model = await loaded()
        await model.confirmDelete()
        #expect(model.dialog == .failed)
        model.startEditing()
        model.editor?.name = "Grab"
        await service.configure { $0.failing = [] }
        async let saving: Void = model.save()
        async let deleting: Void = model.confirmDelete()
        _ = await (saving, deleting)
        #expect(await service.deleted.count + (await service.changes.count) == 1)
    }
}

@Suite("TransactionEditor")
struct TransactionEditorTests {
    @Test("opens on the saved values and groups the amount as typed")
    func fields() {
        var editor = TransactionEditor(Sample.grab)
        #expect(editor.name == "Grab ke Kantor" && editor.amountText == "18.000" && editor.note.isEmpty)
        #expect(editor.categories.allSatisfy { $0.type == .expense })
        editor.amountText = "Rp250000"
        #expect(editor.amountText == "250.000")
        editor.name = "  "
        #expect(!editor.isValid)
    }

    @Test("sends every changed field, trimmed, and nothing else")
    func change() {
        let noted = TransactionChange(note: "x").applied(to: Sample.grab)
        var editor = TransactionEditor(noted)
        #expect(editor.note == "x")
        #expect(editor.change(from: noted).isEmpty)
        editor.name = " Grab "
        editor.amountText = "20000"
        editor.category = .food
        editor.occurredAt = .distantPast
        editor.note = " pagi "
        #expect(
            editor.change(from: noted)
                == TransactionChange(
                    name: "Grab", amount: 20_000, category: .food, occurredAt: .distantPast, note: "pagi"))
    }
}
