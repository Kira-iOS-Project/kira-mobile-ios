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

}
