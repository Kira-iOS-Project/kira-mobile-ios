import APIClient
import Domain
import Foundation
import Observation

/**
 Rencanaku (SKR-04) and the celebration it opens (SKR-05): the plan's accounts with their tags, the
 payment to make next, moving the plan to another account and Tandai Sudah Bayar. The celebration
 is set once, by the payment that settles an account, and cleared when the person dismisses it.
 */
@MainActor
@Observable
package final class PayoffPlanModel {
    /** Empty when the person has not made a plan yet. */
    package private(set) var phase: ScreenPhase<ActivePayoffPlan> = .loading
    /** True while a payment or a move is in flight. */
    package private(set) var isWorking = false
    /** The problem of the last payment or move, which leaves the plan on screen; nil when it worked. */
    package private(set) var actionProblem: AppProblem?
    /** The payment that settled an account, until the person closes the celebration. */
    package private(set) var celebration: DebtPayment?
    /** The name of the account the celebration is for. */
    package private(set) var celebratedName: String?

    private let service: any PayoffPlanService
    private let makePaymentId: @Sendable () -> String
    /** The payment sent and not yet answered, kept so a retry names the same payment. */
    private var pending: PendingPayment?

    /** A model that reads and changes the plan through `service`, naming each payment with `makePaymentId`. */
    package init(
        service: any PayoffPlanService, makePaymentId: @escaping @Sendable () -> String = { UUID().uuidString }
    ) {
        self.service = service
        self.makePaymentId = makePaymentId
    }

    /** Loads the person's plan. */
    package func load() async {
        do {
            phase = .loaded(try await service.active())
        } catch {
            let problem = error as? AppProblem ?? AppProblem()
            phase = problem.knownCode == .payoffPlanNotFound ? .empty : .failed(problem)
        }
    }

    /** Moves the plan to the account `debtId`, which the plan then pays first. */
    package func focus(on debtId: String) async {
        guard !isWorking else { return }
        isWorking = true
        actionProblem = nil
        do {
            phase = .loaded(try await service.setFocus(debtId: debtId))
        } catch {
            actionProblem = error as? AppProblem ?? AppProblem()
        }
        isWorking = false
    }

    /**
     Marks the next payment as paid, opens the celebration when it settles the account and reloads the plan.
     A payment that failed is retried under the same id, and `PAYOFF_PAYMENT_ALREADY_RECORDED` counts as saved.
     */
    package func markPaid() async {
        guard !isWorking, let next = phase.value?.nextPayment else { return }
        isWorking = true
        actionProblem = nil
        do {
            let payment = try await record(next)
            celebration = payment?.paidOff == true ? payment : nil
            celebratedName = celebration == nil ? nil : next.name
            phase = .loaded(try await service.active())
        } catch {
            actionProblem = error as? AppProblem ?? AppProblem()
        }
        isWorking = false
    }

    /** Sends the payment; nil when the API had already saved it under the same id. */
    private func record(_ next: NextPayment) async throws -> DebtPayment? {
        let sent = pending?.matches(next) == true ? pending : nil
        let attempt = sent ?? PendingPayment(debtId: next.debtId, amount: next.amount, id: makePaymentId())
        pending = attempt
        do {
            let payment = try await service.recordPayment(
                debtId: attempt.debtId, amount: attempt.amount, paymentId: attempt.id)
            pending = nil
            return payment
        } catch let problem as AppProblem where problem.knownCode == .payoffPaymentAlreadyRecorded {
            pending = nil
            return nil
        }
    }

    /** Closes the celebration. */
    package func dismissCelebration() {
        celebration = nil
        celebratedName = nil
    }
}

/** A payment on its way to the API: what it pays and the id that names it. */
private struct PendingPayment {
    let debtId: String
    let amount: Int
    let id: String

    /** True when `next` asks for the same payment again. */
    func matches(_ next: NextPayment) -> Bool { debtId == next.debtId && amount == next.amount }
}
