import Domain
import Foundation

/** Rencanaku's plan and payments, as the screens receive them. */
enum PayoffPlanFixtures {
    static func account(
        _ id: String, status: PlanAccountStatus, remaining: Int, original: Int, kind: DebtKind = .paylater
    ) -> PlanAccount {
        PlanAccount(
            id: id, kind: kind, name: "Akun \(id)", remaining: remaining, original: original,
            progressPercent: original == 0 ? 0 : (original - remaining) * 100 / original, monthlyInstalment: 210_000,
            annualInterestRate: 24, dueDay: 5, status: status)
    }

    /** Two consumer accounts, the first in progress, and a motor loan the plan leaves alone. */
    static func plan(focusIsFirst: Bool = true) -> ActivePayoffPlan {
        ActivePayoffPlan(
            id: "plan-1", method: .snowball, extraPayment: 0, startedAt: Date(timeIntervalSince1970: 1_791_000_000),
            accounts: [
                account("a-1", status: focusIsFirst ? .inProgress : .next, remaining: 420_000, original: 600_000),
                account("a-2", status: focusIsFirst ? .next : .inProgress, remaining: 400_000, original: 400_000),
                account("m-1", status: .ongoing, remaining: 13_000_000, original: 15_000_000, kind: .vehicle),
            ],
            nextPayment: NextPayment(
                debtId: focusIsFirst ? "a-1" : "a-2", name: "Akun", amount: 210_000, dueDate: "2026-11-05",
                daysLeft: 20))
    }

    /** A plan whose consumer accounts are all paid. */
    static let donePlan = ActivePayoffPlan(
        id: "plan-1", method: .snowball, extraPayment: 0, startedAt: Date(timeIntervalSince1970: 1_791_000_000),
        accounts: [], nextPayment: nil)

    static let partPayment = DebtPayment(
        debtId: "a-1", paid: 210_000, remaining: 210_000, progressPercent: 65, paidOff: false, nextAccount: nil,
        scoreEstimate: nil)

    static let settledPayment = DebtPayment(
        debtId: "a-1", paid: 420_000, remaining: 0, progressPercent: 100, paidOff: true,
        nextAccount: NextAccount(id: "a-2", name: "Pinjol B"),
        scoreEstimate: ScoreEstimate(before: 66, after: 72, consumerDebtBefore: 50, consumerDebtAfter: 80))
}
