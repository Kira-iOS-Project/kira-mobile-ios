import Foundation
import Testing

@testable import Domain

@Suite("Wallet")
struct WalletTests {
    @Test("retains the account fields and optional due date")
    func fields() {
        let due = Date(timeIntervalSince1970: 1_800_000_000)
        let wallet = Wallet(id: "debt-1", name: "Paylater A", type: .paylater, balance: 420_000, nextDueAt: due)
        #expect(wallet.id == "debt-1")
        #expect(wallet.name == "Paylater A")
        #expect(wallet.type == .paylater)
        #expect(wallet.balance == 420_000)
        #expect(wallet.nextDueAt == due)
        #expect(wallet.dueSoon == false)
        #expect(Wallet(id: "cash", name: "Tunai", type: .cash, balance: 0, dueSoon: false).dueSoon == false)
        #expect(Wallet(id: "other", name: "Other", type: .other, balance: 0).type == .other)
    }
}
