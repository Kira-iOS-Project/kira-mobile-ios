import APIClient
import Domain

/** The list screen's server calls. */
package struct LiveBillsService: BillsService {
    private let api: KiraAPI

    /** Uses the signed-in API client. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** Loads recurring bills and installment schedules owned by the current account. */
    package func bills() async throws -> [RecurringBill] {
        try await api.getBills()
    }

    /** Lists only the owner's liabilities for the installment picker. */
    package func debtAccounts() async throws -> [BillDebtAccount] {
        let overview = try await api.getWalletOverview()
        return overview.accounts.filter { $0.type.isDebt }.map { BillDebtAccount(id: $0.id, name: $0.name) }
    }

    /** Creates the owner's schedule using the generated, bearer-authenticated operation. */
    package func createBill(_ request: BillCreateRequest) async throws -> RecurringBill {
        try await api.createBill(request)
    }
}
