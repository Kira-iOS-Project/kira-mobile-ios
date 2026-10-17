/**
 Rencanaku's API answered with the PelunasanAktif board's sample: Paylater A in progress with
 Rp840.000,00 of Rp1.260.000,00 paid, Paylater B next from November, and Cicilan Motor going on;
 the payment settles Paylater A (PerayaanLunas: 66 → 71, Cicilanmu turun Rp210.000,00), so the
 screen runs in previews and under `-KiraScreen`.
 */
import APIClient
import Domain
import Features
import SwiftUI

nonisolated extension ActivePayoffPlan {
    /** The board's plan, started in October 2026. */
    static let sample = ActivePayoffPlan(
        method: .snowball, startedAt: Date(timeIntervalSince1970: 1_791_601_200),
        accounts: [
            PlanAccount(
                id: "paylater-a", kind: .paylater, name: "Paylater A", remaining: 420_000, original: 1_260_000,
                progressPercent: 67, monthlyInstalment: 210_000, status: .inProgress, payoffMonth: "2026-10",
                payoffDate: "2026-10-25", startMonth: nil
            ),
            PlanAccount(
                id: "paylater-b", kind: .paylater, name: "Paylater B", remaining: 1_150_000, original: 1_150_000,
                progressPercent: 0, monthlyInstalment: 290_000, status: .next, payoffMonth: "2027-01",
                payoffDate: "2027-01-05", startMonth: "2026-11"
            ),
            PlanAccount(
                id: "motor", kind: .vehicle, name: "Cicilan Motor", remaining: 12_740_000, original: 15_000_000,
                progressPercent: 15, monthlyInstalment: 980_000, status: .ongoing, payoffMonth: "2027-12",
                payoffDate: "2027-12-28", startMonth: nil
            ),
        ],
        nextPayment: NextPayment(
            debtId: "paylater-a", name: "Paylater A", amount: 420_000, instalment: 210_000, extra: 210_000,
            dueDate: "2026-10-25", daysLeft: 10))
}

nonisolated extension DebtPayment {
    /** The board's payment: it settles Paylater A, and the plan moves to Paylater B. */
    static let sampleSettled = DebtPayment(
        debtId: "paylater-a", monthlyInstalment: 210_000, paidOff: true,
        nextAccount: NextAccount(id: "paylater-b", name: "Paylater B"),
        scoreEstimate: ScoreEstimate(before: 66, after: 71)
    )
}

/** Answers every call from the sample; `failing` makes payments and moves throw it instead. */
nonisolated struct PreviewPayoffPlanService: PayoffPlanService {
    var plan: ActivePayoffPlan? = .sample
    var payment: DebtPayment = .sampleSettled
    var failing: AppProblem?

    func create(method _: PayoffMethod, extraPayment _: Int) throws -> ActivePayoffPlan { .sample }

    func active() throws -> ActivePayoffPlan {
        guard let plan else { throw AppProblem(code: ProblemCode.payoffPlanNotFound.rawValue) }
        return plan
    }

    func setFocus(debtId _: String) throws -> ActivePayoffPlan {
        if let failing { throw failing }
        return .sample
    }

    func recordPayment(debtId _: String, amount _: Int, paymentId _: String) throws -> DebtPayment {
        if let failing { throw failing }
        return payment
    }
}

#if DEBUG
    #Preview("Rencanaku") {
        NavigationStack { PayoffPlanScreen(service: PreviewPayoffPlanService()) { _ in } }
    }

    #Preview("Perayaan Lunas") {
        PayoffCelebration(paid: PaidOffAccount(payment: .sampleSettled, plan: .sample, name: "Paylater A")) { _ in }
    }
#endif
