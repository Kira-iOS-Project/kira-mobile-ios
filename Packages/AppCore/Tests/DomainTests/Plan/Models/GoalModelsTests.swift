import Domain
import Testing

@Suite("Rencana's models")
struct GoalModelsTests {
    private let day = CalendarDay(year: 2026, month: 10, day: 1)

    private var summary: GoalSummary {
        GoalSummary(
            id: "g1", kind: .wedding, name: "Menikah", targetAmount: 192_937_500, targetDate: day,
            monthlyDeposit: 6_500_000, savedAmount: 15_000_000)
    }

    @Test("a goal keeps its summary, with nothing else unless given")
    func goal() {
        let bare = GoalDetail(summary: summary)
        #expect(bare.id == "g1" && bare.inputs.isEmpty && bare.initialAmount == 0 && !bare.inBudget)
        #expect(bare.deposits.isEmpty && bare.milestones.isEmpty && bare.summary.savedAmount == 15_000_000)
        let deposit = GoalDeposit(id: "d1", amount: 650_000, depositedOn: day)
        let milestone = GoalMilestone(key: .oneWeek, amount: 980_000, reachedOn: nil)
        let full = GoalDetail(
            summary: summary, inputs: ["years": .number(2)], initialAmount: 15_000_000, inBudget: true,
            deposits: [deposit], milestones: [milestone])
        #expect(full.deposits == [deposit] && full.milestones.first?.reachedOn == nil && full.inBudget)
        #expect(MilestoneKey.allCases.map(\.rawValue) == ["one_week", "one_month", "three_months", "target"])
    }

    @Test("a draft keeps the form's inputs as they were written")
    func draft() {
        let draft = GoalDraft(
            kind: .wedding, name: "Menikah",
            inputs: ["years": .number(2), "budget": .text("standard"), "detailed": .flag(true), "note": .empty],
            initialAmount: 15_000_000, monthlyDeposit: 6_500_000, targetAmount: 192_937_500, targetDate: day,
            inBudget: true)
        #expect(draft.inputs["budget"] == .text("standard") && draft.inBudget && draft.initialAmount == 15_000_000)
    }

    @Test("the plan names its ladder, covers and profile as GET /plan does")
    func overview() {
        let detail = LadderDetail(multiple: 1.1, targetMultiple: 6, health: .held, incomeCover: .missing)
        let step = LadderStep(step: 2, key: .emergencyFund, status: .current, detail: detail)
        let prefill = PlanPrefill(essentialExpense: 4_200_000, maritalStatus: .single, monthlyIncome: 7_500_000)
        let plan = PlanOverview(ladder: [step], goals: [summary], prefill: prefill)
        #expect(plan.ladder.first?.detail.targetMultiple == 6 && plan.prefill.monthlyIncome == 7_500_000)
        #expect(LadderStep(step: 4, key: .investing, status: .todo).detail == LadderDetail())
        #expect(plan.prefill.maritalStatus == .single && plan.goals.count == 1)
        #expect(LadderKey.allCases.map(\.rawValue) == ["pay_off_debt", "emergency_fund", "protection", "invest"])
        #expect(LadderStatus.allCases.map(\.rawValue) == ["done", "current", "todo"])
        #expect(RiskProfile.allCases.map(\.rawValue) == ["conservative", "moderate", "aggressive"])
        #expect(Cover.allCases.map(\.rawValue) == ["held", "missing"])
    }
}
