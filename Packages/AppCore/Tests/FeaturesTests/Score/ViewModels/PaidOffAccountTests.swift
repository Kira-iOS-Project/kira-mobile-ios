import Domain
import Testing

@testable import Features

@Suite("PaidOffAccount")
struct PaidOffAccountTests {
    @Test("takes the settled account's place and the plan's size from the plan before the payment")
    func fromPlan() {
        let paid = PaidOffAccount(
            payment: PayoffPlanFixtures.settledPayment, plan: PayoffPlanFixtures.plan(), name: "Paylater A")
        #expect(paid.id == "a-1" && paid.name == "Paylater A" && paid.position == 1 && paid.total == 3)
        #expect(paid.monthlyInstalment == 210_000)
        #expect(paid.nextAccount == NextAccount(id: "a-2", name: "Pinjol B"))
        #expect(paid.scoreEstimate == PayoffPlanFixtures.settledPayment.scoreEstimate)
    }

    @Test("counts accounts already paid off, which the plan keeps first")
    func countsPaidOff() {
        let plan = ActivePayoffPlan(
            id: "plan-1", method: .snowball, extraPayment: 0, startedAt: PayoffPlanFixtures.plan().startedAt,
            accounts: [
                PayoffPlanFixtures.account("p-1", status: .paidOff, remaining: 0, original: 300_000),
                PayoffPlanFixtures.account("a-1", status: .inProgress, remaining: 420_000, original: 600_000),
                PayoffPlanFixtures.account("a-2", status: .next, remaining: 400_000, original: 400_000),
            ],
            nextPayment: PayoffPlanFixtures.plan().nextPayment)
        let paid = PaidOffAccount(payment: PayoffPlanFixtures.settledPayment, plan: plan, name: "Paylater A")
        #expect(paid.position == 2 && paid.total == 3)
    }

    @Test("an account the plan no longer lists has no place, and the last one has nothing next")
    func notListed() {
        let payment = DebtPayment(
            debtId: "gone", paid: 100_000, remaining: 0, monthlyInstalment: 100_000, progressPercent: 100,
            paidOff: true, nextAccount: nil, scoreEstimate: nil)
        let paid = PaidOffAccount(payment: payment, plan: PayoffPlanFixtures.plan(), name: "Akun Lama")
        #expect(paid.position == nil && paid.total == 3 && paid.nextAccount == nil && paid.scoreEstimate == nil)
    }
}
