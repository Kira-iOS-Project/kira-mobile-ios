import APIClient
import Domain

/** Rencanaku's calls over the API client. */
package struct LivePayoffPlanService: PayoffPlanService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `POST /payoff/plans`. */
    package func create(method: PayoffMethod, extraPayment: Int) async throws -> ActivePayoffPlan {
        let dto: PayoffMethodDTO = try Bridge.value(method)
        return try ActivePayoffPlan(try await api.createPayoffPlan(method: dto, extraPayment: extraPayment))
    }

    /** `GET /payoff/plans/active`. */
    package func active() async throws -> ActivePayoffPlan {
        try ActivePayoffPlan(try await api.getActivePayoffPlan())
    }

    /** `PATCH /payoff/plans/active`. */
    package func setFocus(debtId: String) async throws -> ActivePayoffPlan {
        try ActivePayoffPlan(try await api.setPayoffFocus(debtId: debtId))
    }

    /** `POST /debts/{id}/payments`. */
    package func recordPayment(debtId: String, amount: Int) async throws -> DebtPayment {
        DebtPayment(try await api.recordDebtPayment(debtId: debtId, amount: amount))
    }
}
