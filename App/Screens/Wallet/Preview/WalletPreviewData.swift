import Domain
import Foundation

nonisolated enum WalletPreviewData {
    static var accounts: [Wallet] {
        let due = Date.now.addingTimeInterval(7 * 86_400)
        return [
            Wallet(id: "bank-main", name: "BCA", type: .bank, balance: 6_500_000),
            Wallet(id: "ewallet-main", name: "GoPay", type: .ewallet, balance: 850_000),
            Wallet(id: "cash-main", name: "Tunai", type: .cash, balance: 52_000),
            Wallet(id: "paylater-a", name: "Paylater A", type: .paylater, balance: 420_000, nextDueAt: due),
            Wallet(id: "card-main", name: "Kartu Kredit", type: .creditCard, balance: 1_200_000),
            Wallet(id: "pinjol-main", name: "Pinjaman Online", type: .onlineLoan, balance: 3_500_000),
        ]
    }

    static var debt: DebtDetail {
        let account = WalletPreviewData.accounts[3]
        let firstDue = Date.now.addingTimeInterval(7 * 86_400)
        let schedule = (0..<6).map { index in
            DebtInstallment(
                id: "installment-\(index)", dueAt: firstDue.addingTimeInterval(Double(index) * 30 * 86_400),
                amount: 105_000, status: index == 0 ? .dueSoon : .upcoming)
        }
        let payments = (0..<4).map { index in
            DebtPayment(
                id: "payment-\(index)", paidAt: firstDue.addingTimeInterval(Double(index - 4) * 30 * 86_400),
                amount: 45_000, timing: index == 2 ? .late : .onTime)
        }
        return DebtDetail(
            account: account, originalAmount: 600_000, paidInstallments: 4, totalInstallments: 10,
            schedule: schedule, payments: payments,
            scoreEstimate: DebtScoreEstimate(current: 66, afterPayoff: 71))
    }

}
