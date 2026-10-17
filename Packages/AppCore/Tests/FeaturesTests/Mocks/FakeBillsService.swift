import APIClient
import Domain
import Features

/** A controllable schedule list for loading, empty and failure phases. */
actor FakeBillsService: BillsService {
    private let result: Result<[RecurringBill], AppProblem>
    private let accountsResult: Result<[BillDebtAccount], any Error>
    private let createdResult: Result<RecurringBill, any Error>
    private var callCount = 0
    private var accountCallCount = 0
    private var createRequests: [BillCreateRequest] = []

    init(
        bills: Result<[RecurringBill], AppProblem> = .success([]),
        debtAccounts: Result<[BillDebtAccount], any Error> = .success([]),
        created: Result<RecurringBill, any Error> = .success(BillsFixtures.bill)
    ) {
        result = bills
        accountsResult = debtAccounts
        createdResult = created
    }

    func calls() -> Int { callCount }
    func accountCalls() -> Int { accountCallCount }
    func submissions() -> [BillCreateRequest] { createRequests }

    func bills() async throws -> [RecurringBill] {
        callCount += 1
        return try result.get()
    }

    func debtAccounts() async throws -> [BillDebtAccount] {
        accountCallCount += 1
        return try accountsResult.get()
    }

    func createBill(_ request: BillCreateRequest) async throws -> RecurringBill {
        createRequests.append(request)
        return try createdResult.get()
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
