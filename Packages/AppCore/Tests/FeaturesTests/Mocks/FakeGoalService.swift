import APIClient
import Domain
import Foundation

@testable import Features

/** Rencana's API boundary, answering from what a test sets and recording what it was sent. */
actor FakeGoalService: GoalService {
    enum Call: Hashable, Sendable {
        case plan, goals, goal, create, update, deposit
    }

    static let problem = AppProblem(code: "VALIDATION_FAILED", requestId: "req-1")
    static let summary = GoalSummary(
        id: "goal-1", kind: .wedding, name: "Menikah", targetAmount: 192_937_500,
        targetDate: CalendarDay(year: 2028, month: 10, day: 1), monthlyDeposit: 6_500_000, savedAmount: 15_000_000)

    var overview = PlanOverview(
        ladder: [
            LadderStep(step: 1, key: .expensiveDebt, status: .current, detail: LadderDetail(debtName: "Paylater A"))
        ],
        goals: [summary], riskProfile: nil, prefill: PlanPrefill(essentialExpense: 4_200_000))
    /** The calls that fail, and how. */
    var failing: [Call: any Error] = [:]
    private(set) var created: [GoalDraft] = []
    private(set) var updated: [String: GoalDraft] = [:]
    /** The deposits sent, by their id. */
    private(set) var deposits: [String: Int] = [:]

    func configure(_ change: @Sendable (isolated FakeGoalService) -> Void) { change(self) }

    func plan() throws -> PlanOverview {
        try check(.plan)
        return overview
    }

    func goals() throws -> [GoalSummary] {
        try check(.goals)
        return overview.goals
    }

    func goal(id _: String) throws -> GoalDetail {
        try check(.goal)
        return GoalDetail(summary: Self.summary)
    }

    func createGoal(_ draft: GoalDraft) throws -> GoalDetail {
        created.append(draft)
        try check(.create)
        return GoalDetail(summary: Self.summary, inputs: draft.inputs, inBudget: draft.inBudget)
    }

    func updateGoal(id: String, _ draft: GoalDraft) throws -> GoalDetail {
        updated[id] = draft
        try check(.update)
        return GoalDetail(summary: Self.summary, inputs: draft.inputs)
    }

    func addDeposit(goalId _: String, amount: Int, depositedOn: CalendarDay, depositId: String) throws -> GoalDeposit {
        deposits[depositId] = amount
        try check(.deposit)
        return GoalDeposit(id: depositId, amount: amount, depositedOn: depositedOn)
    }

    private func check(_ call: Call) throws {
        if let error = failing[call] { throw error }
    }
}
