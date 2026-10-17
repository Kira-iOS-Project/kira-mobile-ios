import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** The week the API answers, or the error it throws; counts its calls. */
private final class FakeWeeklySummaryService: WeeklySummaryService, @unchecked Sendable {
    var answer: Result<WeeklySummary, any Error>

    init(_ answer: Result<WeeklySummary, any Error>) {
        self.answer = answer
    }

    func weeklySummary() throws -> WeeklySummary { try answer.get() }
}

@MainActor
@Suite("WeeklySummaryModel")
struct WeeklySummaryModelTests {
    private func week(total: Int) -> WeeklySummary {
        let start = CalendarDay(year: 2026, month: 10, day: 8)
        return WeeklySummary(
            start: start, end: start.adding(days: 6), total: total, previousTotal: 0,
            days: [DaySpending(day: start, amount: total)],
            categories: [CategorySpending(category: .food, amount: total)])
    }

    @Test("loads the week; a week without spending is empty")
    func loads() async {
        let model = WeeklySummaryModel(service: FakeWeeklySummaryService(.success(week(total: 1_000))))
        #expect(model.phase.value == nil)
        await model.load()
        #expect(model.phase.value?.total == 1_000)
        let quiet = WeeklySummaryModel(service: FakeWeeklySummaryService(.success(week(total: 0))))
        await quiet.load()
        guard case .empty = quiet.phase else { return #expect(Bool(false)) }
    }

    @Test(
        "a failed load shows the problem, a lost connection as such; Coba Lagi loads again",
        arguments: [
            AppProblem(code: "VALIDATION_FAILED") as any Error, URLError(.notConnectedToInternet) as any Error,
        ])
    func fails(error: any Error) async {
        let service = FakeWeeklySummaryService(.failure(error))
        let model = WeeklySummaryModel(service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem == AppProblem(error))
        service.answer = .success(week(total: 5))
        await model.load()
        #expect(model.phase.value?.total == 5)
    }
}
