import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("DebtDetailModel")
@MainActor
struct DebtDetailModelTests {
    @Test("loads server detail and validates a positive payment against the remaining balance")
    func loadAndValidate() async {
        let detail = sampleDebt()
        let model = DebtDetailModel(id: detail.account.id, service: FakeWalletService(details: [detail]))
        #expect(model.canPay == false)
        await model.load()
        #expect(model.phase.value == detail)
        #expect(model.canPay == false)
        model.amountText = "0"
        #expect(model.canPay == false)
        model.amountText = "420.001"
        #expect(model.canPay == false)
        model.amountText = "420.000"
        #expect(model.canPay)
    }

    @Test("rejects an invalid form without contacting the service")
    func invalidPayment() async {
        let detail = sampleDebt()
        let service = FakeWalletService(details: [detail])
        let model = DebtDetailModel(id: detail.account.id, service: service)
        await model.load()
        await model.pay()
        #expect(model.showsPaymentErrors)
        #expect(model.paymentProblem == nil)
        #expect(await service.recordedPayment() == nil)
        #expect(model.paymentSucceeded == false)
    }

    @Test("records payment, keeps a stable idempotency key on retry, and resets after success")
    func paymentRetryAndSuccess() async {
        let detail = sampleDebt()
        let service = FakeWalletService(details: [detail])
        let model = DebtDetailModel(id: detail.account.id, service: service)
        await model.load()
        await service.configure(failures: [.payment])
        model.amountText = "120.000"
        await model.pay()
        let firstAttempt = await service.recordedPayment()
        #expect(firstAttempt?.request.amount == 120_000)
        #expect(model.paymentProblem?.code == "ROUTE_NOT_FOUND")
        #expect(model.paymentSucceeded == false)
        #expect(model.phase.value == detail)

        await service.configure()
        await model.pay()
        let retry = await service.recordedPayment()
        #expect(retry == firstAttempt)
        #expect(model.phase.value?.account.balance == 300_000)
        #expect(model.phase.value?.payments.first?.amount == 120_000)
        #expect(model.paymentSucceeded)
        #expect(model.paymentProblem == nil)
        #expect(model.isPaying == false)

        model.amountText = "50.000"
        model.resetPaymentForm()
        #expect(model.amountText.isEmpty)
        #expect(model.showsPaymentErrors == false)
        #expect(model.paymentProblem == nil)
        #expect(model.paymentSucceeded == false)
    }

    @Test("surfaces load failures and remains protected while a payment is in flight")
    func failuresAndInFlight() async {
        let detail = sampleDebt()
        let broken = FakeWalletService(details: [detail])
        await broken.configure(failures: [.detail])
        let failed = DebtDetailModel(id: detail.account.id, service: broken)
        await failed.load()
        guard case .failed(let problem) = failed.phase else {
            Issue.record("Expected debt detail load to fail")
            return
        }
        #expect(problem.code == "ROUTE_NOT_FOUND")

        let service = FakeWalletService(details: [detail])
        let model = DebtDetailModel(id: detail.account.id, service: service)
        await model.load()
        await service.configure(delay: .milliseconds(40))
        model.amountText = "1"
        let saving = Task { await model.pay() }
        try? await Task.sleep(for: .milliseconds(5))
        #expect(model.isPaying)
        #expect(model.canPay == false)
        await saving.value
        #expect(model.isPaying == false)
    }

    private func sampleDebt() -> DebtDetail {
        DebtDetail(
            account: Wallet(id: "debt-1", name: "Paylater", type: .paylater, balance: 420_000),
            originalAmount: 600_000, paidInstallments: 4, totalInstallments: 10,
            schedule: [], payments: [], scoreEstimate: DebtScoreEstimate(current: 66, afterPayoff: 71))
    }
}
