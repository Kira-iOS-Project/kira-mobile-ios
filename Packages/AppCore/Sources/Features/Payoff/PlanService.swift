import Domain

/**
 What Rencanaku and the celebration need from the API: `GET` and `PATCH /payoff/plans/active`,
 `POST /payoff/plans` and `POST /debts/{id}/payments`. The integrator implements it with the
 generated client; each call throws an `AppProblem`.
 */
package protocol PlanService: Sendable {
    /** Makes the simulated plan the person's: Jadikan Rencanaku. */
    func create(method: PayoffMethod, extraPayment: Int) async throws -> ActivePayoffPlan
    /** The person's plan; throws `PAYOFF_PLAN_NOT_FOUND` before one is made. */
    func active() async throws -> ActivePayoffPlan
    /** Moves the plan to another account. */
    func setFocus(debtId: String) async throws -> ActivePayoffPlan
    /** Marks `amount` paid on an account: Tandai Sudah Bayar. */
    func recordPayment(debtId: String, amount: Int) async throws -> DebtPayment
}
