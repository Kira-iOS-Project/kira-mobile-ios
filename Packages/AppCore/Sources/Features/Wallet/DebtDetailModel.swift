import APIClient
import Domain
import Foundation
import Observation

/** Detail Utang (UNG-03): loads server calculations and records a payment as a ledger transaction. */
@MainActor
@Observable
package final class DebtDetailModel {
    package private(set) var phase: ScreenPhase<DebtDetail> = .loading
    package var amountText = ""
    package private(set) var isPaying = false
    package private(set) var showsPaymentErrors = false
    package private(set) var paymentProblem: AppProblem?
    package private(set) var paymentSucceeded = false

    private let id: String
    private let service: any WalletService
    private var paymentId = UUID()

    package init(id: String, service: any WalletService) {
        self.id = id
        self.service = service
    }

    /** Loads current balance, installments, payment history, and the simulated score estimate. */
    package func load() async {
        do {
            phase = .loaded(try await service.debt(id: id))
        } catch {
            phase = .failed(walletProblem(error))
        }
    }

    /** Payment must be positive and no greater than the server's remaining balance. */
    package var canPay: Bool {
        guard let detail = phase.value, let amount = AmountInput.amount(amountText) else { return false }
        return amount <= detail.account.balance && !isPaying
    }

    /** Starts a fresh idempotency key when the payment sheet opens. */
    package func resetPaymentForm() {
        amountText = ""
        showsPaymentErrors = false
        paymentProblem = nil
        paymentSucceeded = false
        paymentId = UUID()
    }

    /** Records the amount; a failed attempt keeps the same key so a retry cannot double-pay. */
    package func pay() async {
        showsPaymentErrors = true
        guard let amount = AmountInput.amount(amountText), canPay else { return }
        isPaying = true
        paymentProblem = nil
        paymentSucceeded = false
        defer { isPaying = false }
        do {
            let request = DebtPaymentRequest(paymentId: paymentId, amount: amount)
            phase = .loaded(try await service.payDebt(id: id, request: request))
            paymentSucceeded = true
            paymentId = UUID()
        } catch {
            paymentProblem = walletProblem(error)
        }
    }
}
