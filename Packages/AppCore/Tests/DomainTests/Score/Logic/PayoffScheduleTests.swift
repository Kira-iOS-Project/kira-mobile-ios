import Testing

@testable import Domain

@Suite("PayoffSchedule")
struct PayoffScheduleTests {
    private func account(_ position: Int, month: String?, due: Int?, instalment: Int = 210_000) -> PayoffAccount {
        PayoffAccount(
            id: "a-\(position)", kind: .paylater, name: "Akun \(position)", remaining: 420_000,
            monthlyInstalment: instalment, annualInterestRate: 24, position: position, months: 2,
            payoffMonth: month, interest: 0, dueDay: due)
    }

    private func plan(_ accounts: [PayoffAccount], allPaid: String?) -> PayoffSimulation {
        PayoffSimulation(
            method: .snowball, extraPayment: 210_000, maxExtraPayment: 600_000, monthlyBudget: 1_560_000,
            hasUnknownRate: false, accounts: accounts, productive: [], totalInterest: nil, allPaidMonths: nil,
            allPaidMonth: allPaid, comparison: nil)
    }

    @Test("an account is paid off on its due day, kept inside a short month; without one there is no day")
    func payoffDay() {
        #expect(account(1, month: "2026-10", due: 25).payoffDay == CalendarDay(year: 2026, month: 10, day: 25))
        #expect(account(1, month: "2027-02", due: 31).payoffDay == CalendarDay(year: 2027, month: 2, day: 28))
        #expect(account(1, month: "2026-10", due: 0).payoffDay == CalendarDay(year: 2026, month: 10, day: 1))
        #expect(account(1, month: "2026-10", due: nil).payoffDay == nil)
        #expect(account(1, month: nil, due: 25).payoffDay == nil)
        #expect(account(1, month: "Oktober", due: 25).payoffDay == nil)
    }

    @Test("the first account, the last payoff day, the minimum and when each next account starts")
    func order() {
        let first = account(1, month: "2026-10", due: 25, instalment: 210_000)
        let second = account(2, month: "2027-01", due: 5, instalment: 1_140_000)
        let simulation = plan([second, first], allPaid: "2027-01")
        #expect(simulation.firstAccount == first)
        #expect(simulation.allPaidDay == CalendarDay(year: 2027, month: 1, day: 5))
        #expect(simulation.minimumInstalments == 1_350_000)
        #expect(simulation.previous(of: second) == first && simulation.previous(of: first) == nil)
        #expect(simulation.startMonth(of: second) == CalendarDay(year: 2026, month: 11, day: 1))
        #expect(simulation.startMonth(of: first) == nil)
        #expect(plan([first], allPaid: nil).allPaidDay == nil)
        #expect(plan([], allPaid: nil).firstAccount == nil)
    }
}
