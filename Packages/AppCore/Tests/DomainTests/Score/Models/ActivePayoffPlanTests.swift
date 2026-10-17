import Domain
import Foundation
import Testing

@Suite("ActivePayoffPlan")
struct ActivePayoffPlanTests {
    private let today = CalendarDay(year: 2026, month: 10, day: 15)

    private func account(
        _ id: String, _ status: PlanAccountStatus, remaining: Int = 1, original: Int = 2, payoffMonth: String? = nil,
        payoffDate: String? = nil
    ) -> PlanAccount {
        PlanAccount(
            id: id, kind: .paylater, name: id, remaining: remaining, original: original, progressPercent: 0,
            monthlyInstalment: 1, annualInterestRate: nil, dueDay: nil, status: status, payoffMonth: payoffMonth,
            payoffDate: payoffDate, startMonth: nil)
    }

    private func plan(_ accounts: [PlanAccount]) -> ActivePayoffPlan {
        ActivePayoffPlan(
            id: "p", method: .avalanche, extraPayment: 0, startedAt: Date(timeIntervalSince1970: 0),
            accounts: accounts, nextPayment: nil)
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

    @Test("within a month of the last due date the countdown counts days, today being 0")
    func countdownDays() {
        #expect(plan([account("a", .inProgress, payoffDate: "2026-10-25")]).focusCountdown(today: today) == .days(10))
        #expect(plan([account("a", .inProgress, payoffDate: "2026-10-15")]).focusCountdown(today: today) == .days(0))
        #expect(plan([account("a", .inProgress, payoffDate: "2026-10-01")]).focusCountdown(today: today) == .days(0))
        #expect(plan([account("a", .inProgress, payoffDate: "2026-11-15")]).focusCountdown(today: today) == .days(31))
    }

    @Test("past a month the countdown counts months, at least 1")
    func countdownMonths() {
        #expect(plan([account("a", .inProgress, payoffDate: "2027-01-05")]).focusCountdown(today: today) == .months(3))
        #expect(plan([account("a", .inProgress, payoffDate: "2026-11-30")]).focusCountdown(today: today) == .months(1))
    }

    @Test("without a due date the countdown counts months to the payoff month, at least 1")
    func countdownByMonth() {
        #expect(plan([account("a", .inProgress, payoffMonth: "2027-03")]).focusCountdown(today: today) == .months(5))
        #expect(plan([account("a", .inProgress, payoffMonth: "2026-10")]).focusCountdown(today: today) == .months(1))
    }

    @Test("the countdown is unknown without a focus or anything to count to")
    func countdownUnknown() {
        #expect(plan([account("m", .ongoing, payoffDate: "2026-10-25")]).focusCountdown(today: today) == .unknown)
        #expect(plan([account("a", .inProgress)]).focusCountdown(today: today) == .unknown)
        #expect(plan([account("a", .inProgress, payoffMonth: "bad")]).focusCountdown(today: today) == .unknown)
    }
}
