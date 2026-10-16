import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("ManualEntryModel")
struct ManualEntryModelTests {
    private func model(
        _ service: FakeRecordService, clock: ManualClock = ManualClock(), profile: RecordProfile = Fixtures.profile(),
        saved: @escaping (ManualSaveResult) -> Void = { _ in }
    ) -> ManualEntryModel {
        ManualEntryModel(
            profile: profile, dependencies: Fixtures.dependencies(service: service, clock: clock), onSaved: saved)
    }

    @Test("an expense of the last category used, today, with the board's eight tiles")
    func start() {
        let form = model(FakeRecordService())
        #expect(form.type == .expense)
        #expect(form.category == .shopping)
        #expect(form.categories.count == 8)
        #expect(form.day == Fixtures.noon)
        #expect(!form.canSave)
    }

    @Test("Pemasukan swaps the grid and its default; a last category off the grid falls to the first")
    func income() {
        let form = model(FakeRecordService(), profile: Fixtures.profile(lastExpense: .health, lastIncome: .bonus))
        #expect(form.category == .food)
        form.select(TransactionType.income)
        #expect(form.categories == [.salary, .bonus, .business, .otherIncome])
        #expect(form.category == .bonus)
        form.select(TransactionType.income)
        #expect(form.category == .bonus)
        form.select(.business)
        #expect(form.category == .business)
    }

    @Test("Simpan saves once with today's time, then Transaksi Tersimpan and Selesai close the form")
    func save() async throws {
        let service = FakeRecordService()
        let result = ManualSaveResult(message: Fixtures.kira("k9", kind: .manualSaved))
        service.manualResult = .success(result)
        var received: ManualSaveResult?
        let form = model(service) { received = $0 }
        form.amountText = "45.000"
        form.name = " Belanja Mingguan "
        form.note = "  "
        await form.save()
        let input = try #require(service.manuals.first)
        #expect(input.clientId == "id-1")
        #expect(input.amount == 45_000)
        #expect(input.name == "Belanja Mingguan")
        #expect(input.note == nil)
        #expect(input.occurredAt == Fixtures.noon)
        #expect(received?.message.kind == .manualSaved)
        #expect(form.showsSaved)
        form.finish()
        #expect(form.isClosed)
    }

    @Test("a lost connection keeps the form; Coba Lagi resends the same clientId; a past day is noon WIB")
    func retry() async throws {
        let service = FakeRecordService()
        let form = model(service)
        form.amountText = "7500000"
        form.note = "Oktober"
        form.day = Fixtures.noon.addingTimeInterval(-2 * 86_400)
        await form.save()
        #expect(form.failure == .connection)
        #expect(form.amountText == "7500000")
        service.manualResult = .success(
            ManualSaveResult(message: Fixtures.kira("k", kind: .manualSaved)))
        await form.save()
        #expect(service.manuals.map(\.clientId) == ["id-1", "id-1"])
        #expect(service.manuals.last?.name == "shopping")
        #expect(service.manuals.last?.note == "Oktober")
        let parts = ChatTimeline.calendar.dateComponents(
            [.day, .hour], from: try #require(service.manuals.last).occurredAt)
        #expect(parts.day == 13)
        #expect(parts.hour == 12)
        #expect(form.failure == nil)
    }
}
