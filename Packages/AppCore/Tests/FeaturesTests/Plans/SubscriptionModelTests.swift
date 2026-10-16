import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("SubscriptionModel")
struct SubscriptionModelTests {
    @Test("loads the subscription, or empty on Kira Gratis, or the problem")
    func loads() async {
        let model = SubscriptionModel(service: FakePlansService())
        await model.load()
        #expect(model.phase.value == PlansFixtures.subscription())

        let free = SubscriptionModel(service: FakePlansService(subscriptionResult: .success(nil)))
        await free.load()
        guard case .empty = free.phase else {
            Issue.record("expected empty")
            return
        }

        let broken = SubscriptionModel(service: FakePlansService(subscriptionResult: .failure(problem("X"))))
        await broken.load()
        guard case .failed = broken.phase else {
            Issue.record("expected a failure")
            return
        }
    }

    @Test("cancels in one call and shows the success dialog")
    func cancels() async {
        let service = FakePlansService(changeResult: .success(PlansFixtures.subscription(cancelled: true)))
        let model = SubscriptionModel(service: service)
        await model.load()
        await model.cancel()
        #expect(model.didCancel)
        #expect(!model.isCancelling)
        #expect(model.phase.value?.cancelAtPeriodEnd == true)
        #expect(await service.log.calls == ["subscription", "cancel"])
    }

    @Test("keeps the problem of a refused cancel, such as a scholarship")
    func cancelRefused() async {
        let service = FakePlansService(changeResult: .failure(problem("SUBSCRIPTION_NOT_CANCELLABLE")))
        let model = SubscriptionModel(service: service)
        await model.load()
        await model.cancel()
        #expect(!model.didCancel)
        #expect(model.cancelProblem?.code == "SUBSCRIPTION_NOT_CANCELLABLE")
        #expect(model.phase.value == PlansFixtures.subscription())
    }
}
