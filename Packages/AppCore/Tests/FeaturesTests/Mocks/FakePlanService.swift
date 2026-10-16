import APIClient
import Domain
import Features

/** The API's side of Rencanaku, answered from memory: the network is the boundary replaced here. */
actor FakePlanService: PlanService {
    /** What the screens sent, in order. */
    private(set) var calls: [String] = []
    private var createResult: Result<ActivePayoffPlan, any Error> = .success(PlanFixtures.plan())
    private var activeResult: Result<ActivePayoffPlan, any Error> = .success(PlanFixtures.plan())
    private var focusResult: Result<ActivePayoffPlan, any Error> = .success(PlanFixtures.plan(focusIsFirst: false))
    private var paymentResult: Result<DebtPayment, any Error> = .success(PlanFixtures.partPayment)

    func creates(_ result: Result<ActivePayoffPlan, any Error>) { createResult = result }
    func answersActive(_ result: Result<ActivePayoffPlan, any Error>) { activeResult = result }
    func answersFocus(_ result: Result<ActivePayoffPlan, any Error>) { focusResult = result }
    func answersPayment(_ result: Result<DebtPayment, any Error>) { paymentResult = result }

    func create(method: PayoffMethod, extraPayment: Int) throws -> ActivePayoffPlan {
        calls.append("create \(method.rawValue) \(extraPayment)")
        return try createResult.get()
    }

    func active() throws -> ActivePayoffPlan {
        calls.append("active")
        return try activeResult.get()
    }

    func setFocus(debtId: String) throws -> ActivePayoffPlan {
        calls.append("focus \(debtId)")
        return try focusResult.get()
    }

    func recordPayment(debtId: String, amount: Int) throws -> DebtPayment {
        calls.append("pay \(debtId) \(amount)")
        return try paymentResult.get()
    }
}

/** An error that is not an `AppProblem`, as a transport that fails outside the API would throw. */
struct PlanOtherError: Error {}
