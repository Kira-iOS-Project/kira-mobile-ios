import Testing

@testable import Domain

@Suite("WalletType")
struct WalletTypeTests {
    @Test("only credit products are liabilities")
    func debtTypes() {
        #expect(WalletType.bank.isDebt == false)
        #expect(WalletType.ewallet.isDebt == false)
        #expect(WalletType.cash.isDebt == false)
        #expect(WalletType.creditCard.isDebt)
        #expect(WalletType.paylater.isDebt)
        #expect(WalletType.onlineLoan.isDebt)
        #expect(WalletType.vehicle.isDebt)
        #expect(WalletType.mortgage.isDebt)
        #expect(WalletType.familyLoan.isDebt)
        #expect(WalletType.onlineLoan.rawValue == "pinjol")
        #expect(WalletType.creditCard.rawValue == "credit_card")
        #expect(WalletType.ewallet.rawValue == "e_wallet")
        #expect(WalletType.familyLoan.rawValue == "family_loan")
        #expect(WalletType.other.isDebt == false)
        #expect(WalletType.allCases.count == 10)
    }
}
