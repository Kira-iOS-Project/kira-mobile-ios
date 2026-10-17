import APIClient
import Domain
import Features

/** A controllable schedule list for loading, empty and failure phases. */
actor FakeBillsService: BillsService {
    private let result: Result<[RecurringBill], AppProblem>
    private var callCount = 0

    init(bills: Result<[RecurringBill], AppProblem> = .success([])) { result = bills }

    func calls() -> Int { callCount }

    func bills() async throws -> [RecurringBill] {
        callCount += 1
        return try result.get()
    }
}

enum BillsFixtures {
    static let bill = RecurringBill(
        id: "internet", name: "Internet Rumah", amount: 350_000, category: "bills",
        nextDueDate: CalendarDay(year: 2026, month: 10, day: 22), repeatInterval: "monthly", kind: .bill)

    static func problem(_ code: String) -> AppProblem {
        AppProblem(code: code, requestId: "bill-req")
    }
}
