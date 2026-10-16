/** Beranda's call in each of its three layouts. */
import Domain
import Testing

@testable import APIClient

private let period = #"{"start":"2026-09-25","end":"2026-10-24","nextPayday":"2026-10-25","daysUntilPayday":9}"#

private let overviewJSON = #"""
    {"variant":"overview","today":"2026-10-16","displayName":"Dinda","hideBalances":false,\#
    "period":\#(period),"money":{"income":7500000,"spent":5660000,"remaining":1840000,"perDay":204444,\#
    "spentPercent":75},"step":\#(stepJSON),"stepPosition":{"index":1,"total":3},\#
    "score":{"score":66,"band":"coping","delta":4,"isInitial":false},\#
    "weeklySummary":{"from":"2026-10-09","to":"2026-10-15"},"checklist":null,"debtPlan":null,"microTarget":null}
    """#

private let firstStepsJSON = #"""
    {"variant":"first_steps","today":"2026-10-16","displayName":"Dinda","hideBalances":true,\#
    "period":\#(period),"money":null,"step":null,"stepPosition":null,"score":null,"weeklySummary":null,\#
    "checklist":{"healthCheck":true,"firstTransaction":false,"walletAdded":false,"paydaySet":true},\#
    "debtPlan":null,"microTarget":null}
    """#

private let debtPlanJSON = #"""
    {"variant":"debt_plan","today":"2026-10-16","displayName":"Bima","hideBalances":false,\#
    "period":\#(period),"money":null,"step":\#(stepJSON),"stepPosition":{"index":1,"total":2},\#
    "score":{"score":28,"band":"vulnerable","delta":null,"isInitial":true},"weeklySummary":null,\#
    "checklist":null,"debtPlan":{"paidOff":1600000,"total":20000000,"remaining":18400000,"percent":8},\#
    "microTarget":{"kind":"one_week","current":120000,"target":350000}}
    """#

@Suite("HomeAPI")
struct HomeAPITests {
    @Test("reads the overview")
    func overview() async throws {
        let home = try await KiraAPI.canned(json: overviewJSON).api.getHome()
        #expect(home.variant == .overview && home.today == "2026-10-16" && home.displayName == "Dinda")
        let money = HomeMoneyDTO(
            income: 7_500_000, spent: 5_660_000, remaining: 1_840_000, perDay: 204_444, spentPercent: 75)
        #expect(home.money == money)
        #expect(home.step?.kind == .payOffDebt && home.stepPosition == StepPositionDTO(index: 1, total: 3))
        #expect(home.score == HomeScoreDTO(score: 66, band: .coping, delta: 4, isInitial: false))
        #expect(home.weeklySummary == DateRangeDTO(first: "2026-10-09", last: "2026-10-15"))
        #expect(home.period.daysUntilPayday == 9 && home.checklist == nil && home.debtPlan == nil)
    }

    @Test("reads the first steps and their checklist")
    func firstSteps() async throws {
        let home = try await KiraAPI.canned(json: firstStepsJSON).api.getHome()
        #expect(home.variant == .firstSteps && home.hideBalances && home.money == nil && home.score == nil)
        let checklist = HomeChecklistDTO(
            healthCheck: true, firstTransaction: false, walletAdded: false, paydaySet: true)
        #expect(home.checklist == checklist)
        #expect(home.step == nil && home.stepPosition == nil && home.microTarget == nil)
    }

    @Test("reads the debt plan and the micro target")
    func debtPlan() async throws {
        let home = try await KiraAPI.canned(json: debtPlanJSON).api.getHome()
        #expect(home.variant == .debtPlan && home.score?.band == .vulnerable && home.score?.delta == nil)
        #expect(home.debtPlan == DebtPlanDTO(paidOff: 1_600_000, total: 20_000_000, remaining: 18_400_000, percent: 8))
        #expect(home.microTarget == MicroTargetDTO(kind: .oneWeek, current: 120_000, target: 350_000))
    }

    @Test("throws every problem Beranda answers")
    func problems() async {
        await expectProblems([401]) { _ = try await $0.getHome() }
    }
}
