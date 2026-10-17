import Domain

/**
 What the Rencana Pelunasan screen needs from the API: `POST /payoff/simulate`. The integrator
 implements it with the generated client; the call throws an `AppProblem`.
 */
package protocol PayoffService: Sendable {
    /** The plan for `method` with `extraPayment` on top, without saving it. */
    func simulate(method: PayoffMethod, extraPayment: Int) async throws -> PayoffSimulation
}
