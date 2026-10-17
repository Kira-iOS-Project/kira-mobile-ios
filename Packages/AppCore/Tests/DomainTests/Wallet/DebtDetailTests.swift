import Foundation
import Testing

@testable import Domain

@Suite("DebtDetail")
struct DebtDetailTests {
    @Test("progress uses paid installments and clamps to the progress track")
    func progress() {
        #expect(detail(total: 4, paid: 2).progress == 0.5)
        #expect(detail(total: 0, paid: 0).progress == 0)
        #expect(detail(total: 2, paid: 4).progress == 1)
        #expect(detail(total: 4, paid: -2).progress == 0)
    }

    @Test("keeps the next-step guidance supplied by the debt engine")
    func nextStep() {
        #expect(detail(total: 4, paid: 2, nextStep: "Bayar sesuai jadwal").nextStep == "Bayar sesuai jadwal")
        #expect(detail(total: 4, paid: 2).nextStep.isEmpty)
    }

    private func detail(total: Int, paid: Int, nextStep: String = "") -> DebtDetail {
        DebtDetail(
            account: Wallet(id: "debt", name: "Paylater", type: .paylater, balance: 50),
            originalAmount: 100, paidInstallments: paid, totalInstallments: total,
            schedule: [], payments: [], scoreEstimate: DebtScoreEstimate(current: 66, afterPayoff: 71),
            nextStep: nextStep)
    }
}
