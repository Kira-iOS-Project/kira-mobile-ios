import APIClient
import Domain

@testable import Features

actor FakeBillEditService: BillEditService {
    var billResult: Result<RecurringBill, any Error>
    var updateResult: Result<RecurringBill, any Error>
    var deleteResult: Result<Void, any Error>
    private(set) var loadCount = 0
    private(set) var updates: [(String, BillScheduleUpdate)] = []
    private(set) var deletions: [String] = []

    init(
        bill: Result<RecurringBill, any Error> = .success(BillEditFixtures.bill),
        update: Result<RecurringBill, any Error>? = nil,
        deletion: Result<Void, any Error> = .success(())
    ) {
        billResult = bill
        updateResult = update ?? bill
        deleteResult = deletion
    }

    func bill(id: String) async throws -> RecurringBill {
        loadCount += 1
        return try billResult.get()
    }

    func updateBill(id: String, update: BillScheduleUpdate) async throws -> RecurringBill {
        updates.append((id, update))
        return try updateResult.get()
    }

    func deleteBill(id: String) async throws {
        deletions.append(id)
        try deleteResult.get()
    }

    func setDeleteResult(_ result: Result<Void, any Error>) {
        deleteResult = result
    }

    func calls() -> (loads: Int, updates: [(String, BillScheduleUpdate)], deletions: [String]) {
        (loadCount, updates, deletions)
    }
}

enum BillEditFixtures {
    static let bill = RecurringBill(
        id: "bill-1", name: "Internet Rumah", amount: 350_000, category: "bills",
        nextDueDate: CalendarDay(year: 2026, month: 10, day: 22), repeatInterval: "monthly", kind: .bill)
    static let problem = AppProblem(type: nil, code: "HTTP_ERROR", requestId: "edit-1")
}
