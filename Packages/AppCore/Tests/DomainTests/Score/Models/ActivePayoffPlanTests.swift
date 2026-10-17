import Domain
import Foundation
import Testing

@Suite("ActivePayoffPlan")
struct ActivePayoffPlanTests {
    private func account(
        _ id: String, _ status: PlanAccountStatus, remaining: Int = 1, original: Int = 2, payoffMonth: String? = nil,
        payoffDate: String? = nil
    ) -> PlanAccount {
        PlanAccount(
            id: id, kind: .paylater, name: id, remaining: remaining, original: original, progressPercent: 0,
            monthlyInstalment: 1, status: status, payoffMonth: payoffMonth,
            payoffDate: payoffDate, startMonth: nil)
    }

    private func plan(_ accounts: [PlanAccount], next: NextPayment? = nil) -> ActivePayoffPlan {
        ActivePayoffPlan(
            method: .avalanche, startedAt: Date(timeIntervalSince1970: 0),
            accounts: accounts, nextPayment: next)
    }

    private func payment(_ debtId: String, amount: Int, daysLeft: Int?) -> NextPayment {
        NextPayment(
            debtId: debtId, name: debtId, amount: amount, instalment: amount, extra: 0, dueDate: "2026-10-25",
            daysLeft: daysLeft)
    }

    @Test("the API's spelling of a tag is its raw value")
    func rawValues() {
        #expect(PlanAccountStatus(rawValue: "in_progress") == .inProgress)
        #expect(PlanAccountStatus(rawValue: "next") == .next && PlanAccountStatus(rawValue: "ongoing") == .ongoing)
        #expect(PlanAccountStatus(rawValue: "paid_off") == .paidOff)
    }

    @Test("the focus is the account in progress, and an account's place counts from 1 over every account")
    func focusAndPosition() {
        let three = plan([account("a", .inProgress), account("b", .next), account("m", .ongoing)])
        #expect(three.focus?.id == "a")
        #expect(three.position(of: "a") == 1 && three.position(of: "m") == 3)
        #expect(three.position(of: "x") == nil)
        #expect(three.account("b")?.id == "b" && three.account("x") == nil)
        #expect(plan([account("m", .ongoing)]).focus == nil)
    }

    @Test("what is paid is the original balance less what is left, never below 0")
    func paid() {
        #expect(account("a", .inProgress, remaining: 420_000, original: 1_260_000).paid == 840_000)
        #expect(account("a", .inProgress, remaining: 900, original: 600).paid == 0)
    }

    @Test("when the next payment settles the focus, the countdown is the API's days left, never below 0")
    func countdownDays() {
        let focus = account("a", .inProgress, remaining: 420, payoffDate: "2026-10-25")
        #expect(plan([focus], next: payment("a", amount: 420, daysLeft: 10)).focusCountdown == .days(10))
        #expect(plan([focus], next: payment("a", amount: 500, daysLeft: 0)).focusCountdown == .days(0))
        #expect(plan([focus], next: payment("a", amount: 420, daysLeft: -2)).focusCountdown == .days(0))
    }

    @Test("otherwise the countdown is the focus's payoff date, else its month")
    func countdownDate() {
        let dated = account("a", .inProgress, remaining: 900, payoffMonth: "2027-01", payoffDate: "2027-01-05")
        #expect(plan([dated], next: payment("a", amount: 420, daysLeft: 10)).focusCountdown == .date("2027-01-05"))
        #expect(plan([dated], next: payment("b", amount: 900, daysLeft: 10)).focusCountdown == .date("2027-01-05"))
        #expect(
            plan([account("a", .inProgress, remaining: 1, payoffDate: "2026-11-05")]).focusCountdown
                == .date("2026-11-05"))
        #expect(plan([account("a", .inProgress, payoffMonth: "2027-03")]).focusCountdown == .month("2027-03"))
    }

    @Test("the countdown is unknown without a focus or anything to count to")
    func countdownUnknown() {
        #expect(plan([account("m", .ongoing, payoffDate: "2026-10-25")]).focusCountdown == .unknown)
        #expect(plan([account("a", .inProgress)]).focusCountdown == .unknown)
        let undated = account("a", .inProgress, remaining: 420)
        #expect(plan([undated], next: payment("a", amount: 420, daysLeft: nil)).focusCountdown == .unknown)
    }
}
