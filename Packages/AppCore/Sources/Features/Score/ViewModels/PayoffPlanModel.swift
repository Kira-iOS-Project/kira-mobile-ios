import APIClient
import Domain
import Foundation
import Observation

/**
 Rencanaku (SKR-04) and the celebration it opens (SKR-05): the plan's accounts with their tags, the
 payment to make next, Tandai Sudah Bayar, and moving the plan to the next account ("Lanjut ke
 Paylater B"). The celebration is set once, by the payment that settles an account, and cleared
 when the person leaves it. A payment or a move that fails opens the failure dialog; Coba Lagi
 sends it again, a payment under the same id, which the API records once.
 */
@MainActor
@Observable
package final class PayoffPlanModel {
    /** What failed, for the failure dialog, with what Coba Lagi sends again. */
    package enum Failure: Sendable {
        /** Tandai Sudah Bayar did not go through; Coba Lagi sends it again as `paymentId`. */
        case payment(paymentId: String, AppProblem)
        /** Moving the plan to the account `debtId` did not go through. */
        case focus(debtId: String, AppProblem)

        /** The API's problem. */
        package var problem: AppProblem {
            switch self {
            case .payment(_, let problem), .focus(_, let problem): problem
            }
        }
    }

    /** Empty when the person has not made a plan yet. */
    package private(set) var phase: ScreenPhase<ActivePayoffPlan> = .loading
    /** True while a payment or a move is in flight. */
    package private(set) var isWorking = false
    /** The failed payment or move, until the dialog closes. */
    package var failure: Failure?
    /** The account a payment settled, until the person leaves the celebration. */
    package var celebration: PaidOffAccount?

    private let service: any PayoffPlanService
    private let makePaymentId: @Sendable () -> String

    /** A model that reads and changes the plan through `service`, naming each new payment with `makePaymentId`. */
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
            let problem = AppProblem(error)
            phase = problem.knownCode == .payoffPlanNotFound ? .empty : .failed(problem)
        }
    }

    /** Tandai Sudah Bayar: marks the next payment as paid, as a new payment. */
    package func markPaid() async {
        await pay(paymentId: makePaymentId())
    }

    /**
     Sends the next payment as `paymentId`, opens the celebration when it settles the account, and
     reloads the plan. A payment the API already recorded (a retry of one whose answer was lost)
     counts as saved: the plan reloads, without a dialog. When only the reload fails, the page shows
     the load failure rather than the old plan, so the same payment cannot be marked twice.
     */
    private func pay(paymentId: String) async {
        guard !isWorking, let plan = phase.value, let next = plan.nextPayment else { return }
        isWorking = true
        failure = nil
        defer { isWorking = false }
        do {
            let payment = try await service.recordPayment(
                debtId: next.debtId, amount: next.amount, paymentId: paymentId)
            if payment.paidOff {
                celebration = PaidOffAccount(payment: payment, plan: plan, name: next.name)
            }
        } catch {
            let problem = AppProblem(error)
            guard problem.knownCode == .payoffPaymentAlreadyRecorded else {
                failure = .payment(paymentId: paymentId, problem)
                return
            }
        }
        do {
            phase = .loaded(try await service.active())
        } catch {
            phase = .failed(AppProblem(error))
        }
    }

    /**
     Lanjut ke the next account: moves the plan to the account `paid`'s celebration names. It runs
     once the celebration has gone, so it is given the account rather than reading `celebration`.
     */
    package func continueToNext(after paid: PaidOffAccount) async {
        celebration = nil
        guard let next = paid.nextAccount else { return }
        await focus(on: next.id)
    }

    /**
     Coba Lagi: sends `failed` again. It is passed in because the dialog clears `failure` as it
     closes, before the retry runs.
     */
    package func retry(_ failed: Failure) async {
        switch failed {
        case .payment(let paymentId, _): await pay(paymentId: paymentId)
        case .focus(let debtId, _): await focus(on: debtId)
        }
    }

    /** Leaves the celebration without moving the plan. */
    package func dismissCelebration() {
        celebration = nil
    }

    private func focus(on debtId: String) async {
        guard !isWorking else { return }
        isWorking = true
        failure = nil
        defer { isWorking = false }
        do {
            phase = .loaded(try await service.setFocus(debtId: debtId))
        } catch {
            failure = .focus(debtId: debtId, AppProblem(error))
        }
    }
}
