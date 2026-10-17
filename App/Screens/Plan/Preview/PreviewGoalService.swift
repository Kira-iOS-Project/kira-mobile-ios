/**
 Rencana on the canvas's sample (boards Rencana and DetailTujuan): Dinda on step 1 (Paylater A) with
 her Dana Darurat goal, Rp4.200.000,00 of essential spending. Goals created or changed and deposits
 are kept in memory; nothing leaves the device.
 */
import Domain
import Features

actor PreviewGoalService: GoalService {
    private var stored: [GoalDetail]
    private var nextId = 1

    /** The sample, with the board's goal unless `goals` says otherwise. */
    init(goals: [GoalDetail] = [PreviewGoalService.emergencyFund]) {
        stored = goals
    }

    func plan() -> PlanOverview {
        PlanOverview(
            ladder: [
                LadderStep(
                    step: 1, key: .expensiveDebt, status: .current, detail: LadderDetail(debtName: "Paylater A")),
                LadderStep(
                    step: 2, key: .emergencyFund, status: .todo,
                    detail: LadderDetail(amount: 4_800_000, target: 25_200_000, multiple: 1.1, targetMultiple: 6)),
                LadderStep(
                    step: 3, key: .protection, status: .done, detail: LadderDetail(health: .held, incomeCover: .held)),
                LadderStep(step: 4, key: .investing, status: .todo),
            ],
            goals: stored.map(\.summary),
            prefill: PlanPrefill(
                essentialExpense: 4_200_000, emergencyFund: 4_800_000, maritalStatus: .single, dependants: 0,
                monthlyIncome: 7_500_000))
    }

    func goal(id: String) -> GoalDetail {
        stored.first { $0.id == id } ?? Self.emergencyFund
    }

    func createGoal(_ draft: GoalDraft) -> GoalDetail {
        let goal = GoalDetail(
            summary: GoalSummary(
                id: "goal-\(nextId)", kind: draft.kind, name: draft.name, targetAmount: draft.targetAmount,
                targetDate: draft.targetDate, monthlyDeposit: draft.monthlyDeposit, savedAmount: draft.initialAmount),
            inputs: draft.inputs, initialAmount: draft.initialAmount, inBudget: draft.inBudget)
        nextId += 1
        stored.append(goal)
        return goal
    }

    func updateGoal(id: String, _ draft: GoalDraft) -> GoalDetail {
        var goal = goal(id: id)
        goal.summary.name = draft.name
        goal.summary.targetAmount = draft.targetAmount
        goal.summary.targetDate = draft.targetDate
        goal.summary.monthlyDeposit = draft.monthlyDeposit
        goal.inputs = draft.inputs
        goal.initialAmount = draft.initialAmount
        replace(goal)
        return goal
    }

    func addDeposit(goalId: String, amount: Int, depositedOn: CalendarDay, depositId: String) -> GoalDeposit {
        var goal = goal(id: goalId)
        let deposit = GoalDeposit(id: depositId, amount: amount, depositedOn: depositedOn)
        guard !goal.deposits.contains(where: { $0.id == depositId }) else { return deposit }
        goal.deposits.insert(deposit, at: 0)
        goal.summary.savedAmount += amount
        replace(goal)
        return deposit
    }

    private func replace(_ goal: GoalDetail) {
        stored = stored.map { $0.id == goal.id ? goal : $0 }
    }

    /** DetailTujuan: Rp4.800.000,00 of Rp25.200.000,00, Rp650.000,00 a month, April 2029. */
    static let emergencyFund = GoalDetail(
        summary: GoalSummary(
            id: "emergency", kind: .emergencyFund, name: "Dana Darurat", targetAmount: 25_200_000,
            targetDate: CalendarDay(year: 2029, month: 4, day: 1), monthlyDeposit: 650_000, savedAmount: 4_800_000),
        inputs: ["essentialExpense": .number(4_200_000)], initialAmount: 3_100_000,
        deposits: [
            GoalDeposit(id: "deposit-3", amount: 600_000, depositedOn: CalendarDay(year: 2026, month: 9, day: 25)),
            GoalDeposit(id: "deposit-2", amount: 600_000, depositedOn: CalendarDay(year: 2026, month: 8, day: 25)),
            GoalDeposit(id: "deposit-1", amount: 500_000, depositedOn: CalendarDay(year: 2026, month: 7, day: 25)),
        ],
        milestones: [
            GoalMilestone(key: .oneWeek, amount: 980_000, reachedOn: CalendarDay(year: 2026, month: 3, day: 25)),
            GoalMilestone(key: .oneMonth, amount: 4_200_000, reachedOn: CalendarDay(year: 2026, month: 9, day: 25)),
            GoalMilestone(key: .threeMonths, amount: 12_600_000, reachedOn: nil),
            GoalMilestone(key: .target, amount: 25_200_000, reachedOn: nil),
        ])
}
