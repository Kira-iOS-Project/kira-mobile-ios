import APIClient
import Domain
import Observation

/** Langganan (AKN-07, AKN-07b, AKN-07c): the subscription, its quotas and the one-tap cancel. */
@MainActor
@Observable
package final class SubscriptionModel {
    /** The subscription; `.empty` on Kira Gratis. */
    package private(set) var phase: ScreenPhase<Subscription> = .loading
    /** Whether the cancel request is on its way. */
    package private(set) var isCancelling = false
    /** Set once the cancel succeeded: the "Langganan Dibatalkan" dialog shows. */
    package var didCancel = false
    /** The problem of a refused cancel, shown under the button. */
    package private(set) var cancelProblem: AppProblem?

    private let service: any PlansService

    /** The screen for the person's subscription. */
    package init(service: any PlansService) {
        self.service = service
    }

    /** Loads the subscription. */
    package func load() async {
        phase = .loading
        do {
            if let subscription = try await service.subscription() {
                phase = .loaded(subscription)
            } else {
                phase = .empty
            }
        } catch {
            phase = .failed(plansProblem(error))
        }
    }

    /** Cancels at the end of the period, after the person confirmed (AKN-07b). */
    package func cancel() async {
        isCancelling = true
        cancelProblem = nil
        do {
            phase = .loaded(try await service.cancelSubscription())
            didCancel = true
        } catch {
            cancelProblem = plansProblem(error)
        }
        isCancelling = false
    }
}
