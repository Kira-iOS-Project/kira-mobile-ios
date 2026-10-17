import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("BillsModel")
struct BillsModelTests {
    @Test("sorts by due date then name and groups overdue, current month and later schedules")
    func grouping() {
        let today = CalendarDay(year: 2026, month: 1, day: 10)
        let rows = [
            bill("march", "Maret", 2026, 3, 1), bill("later", "Nanti", 2026, 1, 18),
            bill("early", "Awal", 2026, 1, 17), bill("overdue", "Terlambat", 2026, 1, 8),
            bill("next-month", "Februari", 2026, 2, 1), bill("same-day", "Akhir", 2026, 1, 17),
        ]
        let content = BillsContent(bills: rows, today: today)
        #expect(content.bills.map(\.id) == ["overdue", "same-day", "early", "later", "next-month", "march"])
        #expect(content.sections.map(\.kind) == [.nextSevenDays, .thisMonth, .nextMonth, .later])
        #expect(content.sections.map(\.id) == [.nextSevenDays, .thisMonth, .nextMonth, .later])
        #expect(content.sections[0].bills.map(\.id) == ["overdue", "same-day", "early"])
        #expect(content.sections[1].bills.map(\.id) == ["later"])
        #expect(content.sections[2].bills.map(\.id) == ["next-month"])
    }

    @Test("leaves no empty section and includes dates seven days ahead")
    func emptySections() {
        let content = BillsContent(
            bills: [bill("week", "Pekan Ini", 2026, 1, 17)], today: CalendarDay(year: 2026, month: 1, day: 10))
        #expect(content.sections.count == 1)
        #expect(content.sections[0].kind == .nextSevenDays)
    }

    @Test("loads nonempty rows using the injected WIB day")
    func load() async throws {
        let service = FakeBillsService(bills: .success([BillsFixtures.bill]))
        let model = BillsModel(service: service, today: { CalendarDay(year: 2026, month: 10, day: 17) })
        await model.load()
        #expect(try #require(model.phase.value).bills == [BillsFixtures.bill])
        await model.load()
        #expect(try #require(model.phase.value).bills == [BillsFixtures.bill])
        #expect(await service.calls() == 2)

        // Also cover the production clock provider used when the screen is not under test.
        let defaultModel = BillsModel(service: FakeBillsService(bills: .success([BillsFixtures.bill])))
        await defaultModel.load()
        #expect(try #require(defaultModel.phase.value?.bills) == [BillsFixtures.bill])
    }

    @Test("shows an empty phase when there are no schedules")
    func empty() async {
        let model = BillsModel(service: FakeBillsService())
        await model.load()
        guard case .empty = model.phase else {
            Issue.record("expected empty")
            return
        }
    }

    @Test("shows the API problem or a generic problem")
    func failure() async {
        let problem = BillsFixtures.problem("HTTP_ERROR")
        let model = BillsModel(service: FakeBillsService(bills: .failure(problem)))
        await model.load()
        guard case .failed(let failure) = model.phase else {
            Issue.record("expected failure")
            return
        }
        #expect(failure == problem)
        struct Offline: Error {}
        #expect(billsProblem(Offline()) == AppProblem())
        #expect(billsProblem(problem) == problem)
    }

    private func bill(_ id: String, _ name: String, _ year: Int, _ month: Int, _ day: Int) -> RecurringBill {
        RecurringBill(
            id: id, name: name, amount: 100, category: "bills",
            nextDueDate: CalendarDay(year: year, month: month, day: day),
            repeatInterval: "monthly", kind: .bill)
    }
}
