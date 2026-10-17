/**
 Rencanaku's API answered with the canvas's sample data (the same Paylater A and Pinjol B as the
 payoff plan, and Cicilan Motor left out), so the screen runs in previews and in the app before
 integration.
 */
import Domain
import Features
import SwiftUI

nonisolated extension ActivePayoffPlan {
    /** The board's plan: Snowball, Paylater A in progress, Pinjol B next, the motor loan going on. */
    static let sample = ActivePayoffPlan(
        id: "plan-sample", method: .snowball, extraPayment: 200_000,
        startedAt: Date(timeIntervalSince1970: 1_791_601_200),
        accounts: [
            PlanAccount(
                id: "paylater-a", kind: .paylater, name: "Paylater A", remaining: 420_000, original: 600_000,
                progressPercent: 30, monthlyInstalment: 210_000, annualInterestRate: 24, dueDay: 5,
                status: .inProgress),
            PlanAccount(
                id: "pinjol-b", kind: .onlineLoan, name: "Pinjol B", remaining: 890_000, original: 890_000,
                progressPercent: 0, monthlyInstalment: 290_000, annualInterestRate: 36, dueDay: 12, status: .next),
            PlanAccount(
                id: "motor", kind: .vehicle, name: "Cicilan Motor", remaining: 13_000_000, original: 15_000_000,
                progressPercent: 13, monthlyInstalment: 850_000, annualInterestRate: nil, dueDay: nil,
                status: .ongoing),
        ],
        nextPayment: NextPayment(
            debtId: "paylater-a", name: "Paylater A", amount: 210_000, dueDate: "2026-11-05", daysLeft: 20))
}

nonisolated struct PreviewPayoffPlanService: PayoffPlanService {
    func create(method _: PayoffMethod, extraPayment _: Int) throws -> ActivePayoffPlan { .sample }

    func active() throws -> ActivePayoffPlan { .sample }

    func setFocus(debtId _: String) throws -> ActivePayoffPlan { .sample }

    func recordPayment(debtId: String, amount: Int, paymentId _: String) throws -> DebtPayment {
        DebtPayment(
            debtId: debtId, paid: amount, remaining: 210_000, progressPercent: 65, paidOff: false, nextAccount: nil,
            scoreEstimate: nil)
    }
}

#if DEBUG
    #Preview("Rencanaku") {
        NavigationStack { PayoffPlanScreen(service: PreviewPayoffPlanService()) { _ in } }
    }
#endif
