/**
 The payoff plan's API answered with the canvas's sample data (boards RencanaPelunasan and
 RencanaPelunasanAvalanche: Dinda's Paylater A and Pinjol B, and Cicilan Motor left out), so the
 screen runs in previews and in the app before integration.
 */
import Domain
import Features
import SwiftUI

nonisolated extension PayoffSimulation {

    /** The sample plan for `method` and `extraPayment`; Avalanche puts Pinjol B, the dearer, first. */
    static func sample(method: PayoffMethod, extraPayment: Int) -> PayoffSimulation {
        let paylater = PayoffAccount(
            id: "paylater-a", kind: .paylater, name: "Paylater A", remaining: 420_000, monthlyInstalment: 210_000,
            position: method == .snowball ? 1 : 2, payoffMonth: "2026-11"
        )
        let loan = PayoffAccount(
            id: "pinjol-b", kind: .onlineLoan, name: "Pinjol B", remaining: 890_000, monthlyInstalment: 290_000,
            position: method == .snowball ? 2 : 1, payoffMonth: "2026-12"
        )
        return PayoffSimulation(
            method: method, extraPayment: extraPayment, maxExtraPayment: 1_840_000, hasUnknownRate: false,
            accounts: method == .snowball ? [paylater, loan] : [loan, paylater],
            productive: [
                ProductiveDebt(id: "motor", kind: .vehicle, name: "Cicilan Motor", remaining: 13_000_000)
            ], allPaidMonth: "2026-12",
            comparison: PayoffComparison(
                interestSaved: method == .snowball ? -1_200 : 1_200,
                firstPayoffMonthsLater: method == .snowball ? 1 : -1))
    }
}

nonisolated struct PreviewPayoffService: PayoffService {
    func simulate(method: PayoffMethod, extraPayment: Int) throws -> PayoffSimulation {
        .sample(method: method, extraPayment: extraPayment)
    }
}

#if DEBUG
    #Preview("Rencana Pelunasan") {
        NavigationStack { PayoffScreen(service: PreviewPayoffService(), plans: PreviewPayoffPlanService()) { _ in } }
    }
#endif
