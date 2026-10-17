import APIClient
import Domain
import Observation

/**
 Rencana Pelunasan (SKR-03, SKR-03b, SKR-03c): the method, the extra payment, the plan they make
 and the "Gimana Ngitungnya?" accordion. The plan is recomputed by the API on each change; an
 answer that arrives after a newer request is dropped.
 */
@MainActor
@Observable
package final class PayoffModel {
    /** Empty when the person has no consumer debt to plan. */
    package private(set) var phase: ScreenPhase<PayoffSimulation> = .loading
    /** The method chosen: Snowball opens the screen. */
    package private(set) var method: PayoffMethod = .snowball
    /** The extra payment as the field shows it, grouped with dots. */
    package private(set) var extraText = ""
    /** Whether "Gimana Ngitungnya?" is open; the screen's own state, never sent. */
    package var isHowOpen = false
    /** True while a recomputation is in flight. */
    package private(set) var isRecalculating = false
    /** The problem of the last recomputation, which leaves the plan on screen as it was; nil when it worked. */
    package private(set) var recalculationProblem: AppProblem?

    /** True while Jadikan Rencanaku is in flight. */
    package private(set) var isMakingPlan = false
    /** The problem of the last Jadikan Rencanaku; nil when it worked or has not run. */
    package private(set) var makePlanProblem: AppProblem?

    private let service: any PayoffService
    private var generation = 0

    /** A model that simulates through `service`. */
    package init(service: any PayoffService, method: PayoffMethod = .snowball, showsHow: Bool = false) {
        self.service = service
        self.method = method
        isHowOpen = showsHow
    }

    /** The extra payment in whole rupiah; 0 while the field is empty. */
    package var extraPayment: Int { AmountInput.value(of: extraText) ?? 0 }

    /** The most the extra payment may be, once a plan is on screen. */
    package var maxExtraPayment: Int? { phase.value?.maxExtraPayment }

    /** Whether the extra payment is more than the money left this payday period: the field shows its hint. */
    package var exceedsMaximum: Bool {
        guard let maximum = maxExtraPayment else { return false }
        return extraPayment > maximum
    }

    /** Loads the plan for the method and the extra payment on screen. */
    package func load() async {
        await recalculate()
    }

    /** Switches the method (SKR-03 and SKR-03c) and recomputes. */
    package func choose(_ method: PayoffMethod) async {
        guard method != self.method else { return }
        self.method = method
        await recalculate()
    }

    /** Takes what the person typed in the extra payment field, keeps its digits and recomputes. */
    package func setExtra(_ text: String) async {
        let digits = AmountInput.digits(of: text)
        extraText = AmountInput.grouped(digits)
        guard !exceedsMaximum else {
            generation += 1
            isRecalculating = false
            return
        }
        await recalculate()
    }

    /** Makes the plan on screen the person's through `plans`; true when it is saved and Rencanaku can open. */
    package func makePlan(using plans: any PayoffPlanService) async -> Bool {
        guard !isMakingPlan, phase.value != nil, !exceedsMaximum else { return false }
        isMakingPlan = true
        makePlanProblem = nil
        defer { isMakingPlan = false }
        do {
            _ = try await plans.create(method: method, extraPayment: extraPayment)
            return true
        } catch {
            makePlanProblem = error as? AppProblem ?? AppProblem()
            return false
        }
    }

    private func recalculate() async {
        generation += 1
        let mine = generation
        isRecalculating = true
        do {
            let simulation = try await service.simulate(method: method, extraPayment: extraPayment)
            guard mine == generation else { return }
            phase = .loaded(simulation)
            recalculationProblem = nil
        } catch {
            guard mine == generation else { return }
            let problem = error as? AppProblem ?? AppProblem()
            if problem.knownCode == .payoffNothingToPlan {
                phase = .empty
            } else if phase.value == nil {
                phase = .failed(problem)
            } else {
                recalculationProblem = problem
            }
        }
        isRecalculating = false
    }
}
