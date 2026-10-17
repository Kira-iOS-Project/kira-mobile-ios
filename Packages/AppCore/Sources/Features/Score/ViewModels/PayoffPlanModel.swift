import APIClient
import Domain
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

    /** A model that reads and changes the plan through `service`. */
    package init(service: any PayoffPlanService) {
        self.service = service
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

    /** Marks the next payment as paid, opens the celebration when it settles the account and reloads the plan. */
    package func markPaid() async {
        guard !isWorking, let next = phase.value?.nextPayment else { return }
        isWorking = true
        actionProblem = nil
        do {
            let payment = try await service.recordPayment(debtId: next.debtId, amount: next.amount)
            celebration = payment.paidOff ? payment : nil
            celebratedName = payment.paidOff ? next.name : nil
            phase = .loaded(try await service.active())
        } catch {
            actionProblem = error as? AppProblem ?? AppProblem()
        }
        isWorking = false
    }

    /** Closes the celebration. */
    package func dismissCelebration() {
        celebration = nil
        celebratedName = nil
    }
}
