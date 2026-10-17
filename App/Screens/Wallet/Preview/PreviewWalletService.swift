import Domain
import Features
import Foundation

actor PreviewWalletService: WalletService {
    private var accounts = WalletPreviewData.accounts

    func overview() async throws -> WalletOverview {
        try await pause()
        return WalletOverview(accounts: accounts)
    }

    func createWallet(type: WalletType, name: String, balance: Int) async throws -> Wallet {
        try await pause()
        let wallet = Wallet(id: UUID().uuidString, name: name, type: type, balance: balance)
        accounts.append(wallet)
        return wallet
    }

    func debt(id: String) async throws -> DebtDetail {
        try await pause()
        return WalletPreviewData.debt
    }

    func payDebt(id: String, request: DebtPaymentRequest) async throws -> DebtDetail {
        try await pause()
        let old = WalletPreviewData.debt
        let amount = min(request.amount, old.account.balance)
        let updatedAccount = Wallet(
            id: old.account.id, name: old.account.name, type: old.account.type,
            balance: old.account.balance - amount, nextDueAt: old.account.nextDueAt, dueSoon: old.account.dueSoon)
        let payment = DebtPayment(
            id: request.paymentId.uuidString, paidAt: Date.now, amount: amount, timing: .onTime)
        return DebtDetail(
            account: updatedAccount, originalAmount: old.originalAmount,
            paidInstallments: old.paidInstallments, totalInstallments: old.totalInstallments,
            schedule: old.schedule, payments: [payment] + old.payments, scoreEstimate: old.scoreEstimate)
    }

    private func pause() async throws {
        try await Task.sleep(for: .milliseconds(180))
    }
}
