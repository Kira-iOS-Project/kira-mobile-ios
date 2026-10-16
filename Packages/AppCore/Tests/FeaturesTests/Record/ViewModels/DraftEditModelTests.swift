import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("DraftEditModel")
struct DraftEditModelTests {
    private let grab = Fixtures.draft("d2", name: "Grab ke Kantor", amount: 18_000, category: .transport)
    private let lunch = Fixtures.draft("d1", name: "Makan Siang", amount: 25_000)

    private func model(
        _ service: FakeRecordService, item: DraftItem? = nil, updated: @escaping (ChatMessage) -> Void = { _ in }
    )
        -> DraftEditModel
    {
        let message = Fixtures.drafts("k1", replyTo: "m1", items: [lunch, grab])
        return DraftEditModel(
            item: item ?? grab, in: message, sourceTime: Fixtures.noon, service: service, onUpdated: updated)
    }

    @Test("the sheet starts from the draft, with the board's categories and the draft's first")
    func start() {
        let editor = model(FakeRecordService())
        #expect(editor.id == "d2")
        #expect(editor.name == "Grab ke Kantor")
        #expect(editor.amountText == "18.000")
        #expect(editor.categories == [.transport, .food, .shopping, .otherExpense])
        #expect(editor.occurredAt == Fixtures.noon)
        #expect(editor.sourceTime == Fixtures.noon)
        let salary = Fixtures.draft("d9", name: "Gaji", amount: 1_000, category: .bonus)
        #expect(model(FakeRecordService(), item: salary).categories == [.bonus, .salary, .business, .otherIncome])
    }

    @Test("Simpan sends the whole list with this draft changed, then shows Perubahan Tersimpan")
    func save() async throws {
        let service = FakeRecordService()
        let saved = Fixtures.drafts("k1", replyTo: "m1", items: [lunch])
        service.updateResult = .success(saved)
        var received: ChatMessage?
        let editor = model(service) { received = $0 }
        editor.name = "  Ojek ke Kantor "
        editor.amountText = "Rp20000"
        editor.select(.otherExpense)
        await editor.save()
        let update = try #require(service.updates.first)
        #expect(update.messageId == "k1")
        #expect(update.drafts.map(\.name) == ["Makan Siang", "Ojek ke Kantor"])
        #expect(update.drafts.map(\.amount) == [25_000, 20_000])
        #expect(update.drafts.last?.category == .otherExpense)
        #expect(received == saved)
        #expect(editor.showsSaved)
        editor.finish()
        #expect(!editor.showsSaved)
        #expect(editor.isClosed)
    }

    @Test("an empty name or a zero amount stays in the open sheet; a failed save closes it, Coba Lagi saves")
    func invalidAndFailed() async {
        let service = FakeRecordService()
        let editor = model(service)
        editor.amountText = "0"
        #expect(!editor.canSave)
        await editor.save()
        #expect(service.updates.isEmpty && editor.sheet.isOpen)
        editor.amountText = "5000"
        editor.name = " "
        #expect(!editor.canSave)
        editor.name = "Parkir"
        await editor.save()
        #expect(!editor.sheet.isOpen && editor.sheet.failure?.isConnectionLoss == true)
        #expect(!editor.showsSaved)
        #expect(!editor.isSaving)
        service.updateResult = .success(Fixtures.drafts("k1", replyTo: "m1", items: [lunch]))
        await editor.retry()
        #expect(editor.sheet.isOpen && editor.showsSaved && editor.name == "Parkir")
        #expect(service.updates.count == 2 && !editor.lastWasDelete)
    }

    @Test("Hapus dari Draf asks first, then sends the list without this draft and closes")
    func delete() async throws {
        let service = FakeRecordService()
        service.updateResult = .success(Fixtures.drafts("k1", replyTo: "m1", items: [lunch]))
        let editor = model(service)
        editor.requestDelete()
        #expect(editor.confirmsDelete)
        await editor.delete()
        #expect(!editor.confirmsDelete)
        #expect(try #require(service.updates.first).drafts.map(\.id) == ["d1"])
        #expect(editor.isClosed)
        let failing = model(FakeRecordService())
        await failing.delete()
        #expect(!failing.isClosed && failing.lastWasDelete)
        #expect(failing.sheet.failure?.isConnectionLoss == true)
        await failing.retry()
        #expect(!failing.sheet.isOpen && failing.sheet.failure != nil && !failing.isClosed)
    }

    @Test("a card without drafts edits an empty list")
    func emptyCard() async throws {
        let service = FakeRecordService()
        let message = ChatMessage(id: "k1", sender: .kira, kind: .drafts, createdAt: Fixtures.noon)
        let editor = DraftEditModel(item: grab, in: message, sourceTime: Fixtures.noon, service: service) { _ in }
        await editor.save()
        await editor.delete()
        #expect(service.updates.map(\.drafts.count) == [0, 0])
    }
}
