import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("PaymentMethodModel")
struct PaymentMethodModelTests {
    @Test("checks the current method, QRIS when there is none")
    func initial() {
        #expect(PaymentMethodModel(current: .appStore, service: FakePlansService()).paymentMethod == .appStore)
        #expect(PaymentMethodModel(current: nil, service: FakePlansService()).paymentMethod == .qris)
    }

    @Test("saves the checked method")
    func saves() async {
        let service = FakePlansService()
        let model = PaymentMethodModel(current: .qris, service: service)
        model.paymentMethod = .appStore
        await model.save()
        guard case .saved = model.phase else {
            Issue.record("expected saved")
            return
        }
        #expect(await service.log.calls == ["method app_store"])
    }

    @Test("keeps the problem of a refused save")
    func fails() async {
        let model = PaymentMethodModel(
            current: .qris, service: FakePlansService(changeResult: .failure(problem("SUBSCRIPTION_NOT_FOUND"))))
        guard case .ready = model.phase else {
            Issue.record("expected ready")
            return
        }
        await model.save()
        guard case .failed(let failure) = model.phase else {
            Issue.record("expected a failure")
            return
        }
        #expect(failure.code == "SUBSCRIPTION_NOT_FOUND")
    }
}
