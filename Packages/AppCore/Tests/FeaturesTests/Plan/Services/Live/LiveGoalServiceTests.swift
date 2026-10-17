import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LiveGoalService")
struct LiveGoalServiceTests {
    @Test("GET /plan and /goals map the ladder, the goals and the prefill")
    func plan() async throws {
        let (api, _) = KiraAPI.routed([
            "GET /api/plan": ok(planJSON), "GET /api/goals": ok(#"{"goals":[\#(summaryJSON)]}"#),
        ])
        let service = LiveGoalService(api: api)
        let plan = try await service.plan()
        #expect(plan.ladder.map(\.key) == [.expensiveDebt, .emergencyFund, .protection, .investing])
        #expect(plan.ladder[0].detail.debtName == "Paylater A" && plan.ladder[1].detail.targetMultiple == 6)
        #expect(plan.ladder[2].detail.health == .held && plan.ladder[2].detail.incomeCover == .missing)
        #expect(plan.riskProfile == .moderate && plan.prefill.maritalStatus == .married)
        #expect(plan.prefill.essentialExpense == 4_200_000 && plan.prefill.monthlyIncome == 7_500_000)
        #expect(plan.goals.first?.targetDate == CalendarDay(year: 2029, month: 4, day: 25))
    }

    @Test("GET /goals/{id} maps deposits and milestones; POST deposits sends its key and the day")
    func goalAndDeposit() async throws {
        let (api, transport) = KiraAPI.routed([
            "GET /api/goals/e": ok(goalDetailJSON),
            "POST /api/goals/e/deposits": ok(#"{"id":"k-1","amount":650000,"depositedOn":"2026-10-17"}"#, status: 201),
        ])
        let service = LiveGoalService(api: api)
        let goal = try await service.goal(id: "e")
        #expect(goal.deposits.map(\.amount) == [600_000] && goal.inputs["essentialExpense"] == .number(4_200_000))
        #expect(goal.milestones.map(\.key) == [.oneWeek, .target] && goal.milestones[1].reachedOn == nil)
        let deposit = try await service.addDeposit(
            goalId: "e", amount: 650_000, depositedOn: CalendarDay(year: 2026, month: 10, day: 17), depositId: "k-1")
        #expect(deposit.id == "k-1")
        let sent = await transport.sent
        #expect(sent[1].json["depositId"] == .string("k-1") && sent[1].json["depositedOn"] == .string("2026-10-17"))
    }

    @Test("POST /goals sends the draft with its inputs")
    func createAndUpdate() async throws {
        let (api, transport) = KiraAPI.routed([
            "POST /api/goals": ok(goalJSON, status: 201)
        ])
        let service = LiveGoalService(api: api)
        let draft = GoalDraft(
            kind: .emergencyFund, name: "Dana Darurat",
            inputs: [
                "essentialExpense": .number(4_200_000), "note": .text("x"), "married": .flag(true), "skip": .empty,
            ],
            initialAmount: 4_800_000, monthlyDeposit: 650_000, targetAmount: 25_200_000,
            targetDate: CalendarDay(year: 2029, month: 4, day: 25), inBudget: true)
        #expect(try await service.createGoal(draft).id == "e")
        let sent = await transport.sent
        #expect(
            sent[0].json["kind"] == .string("emergency_fund") && sent[0].json["targetDate"] == .string("2029-04-25"))
        #expect(sent[0].json["monthlyDeposit"] == .number(650_000))
    }

    @Test("a gone goal, a second emergency fund and a reused deposit key are thrown as their problems")
    func failures() async {
        let (api, _) = KiraAPI.routed([
            "GET /api/goals/gone": problem("GOAL_NOT_FOUND", status: 404),
            "POST /api/goals/e/deposits": problem("GOAL_DEPOSIT_CONFLICT", status: 409),
            "GET /api/plan": problem("AUTH_UNAUTHENTICATED", status: 401),
        ])
        let service = LiveGoalService(api: api)
        let gone = await #expect(throws: AppProblem.self) { try await service.goal(id: "gone") }
        #expect(gone?.knownCode == .goalNotFound)
        let conflict = await #expect(throws: AppProblem.self) {
            try await service.addDeposit(
                goalId: "e", amount: 1, depositedOn: CalendarDay(year: 2026, month: 10, day: 17), depositId: "k")
        }
        #expect(conflict?.knownCode == .goalDepositConflict)
        await #expect(throws: AppProblem.self) { try await service.plan() }
    }
}

private let summaryJSON =
    #"{"id":"e","kind":"emergency_fund","name":"Dana Darurat","targetAmount":25200000,"targetDate":"2029-04-25","#
    + #""monthlyDeposit":650000,"savedAmount":4800000}"#
private let goalJSON =
    #"{"id":"e","kind":"emergency_fund","name":"Dana Darurat","targetAmount":25200000,"targetDate":"2029-04-25","#
    + #""monthlyDeposit":650000,"savedAmount":4800000,"inputs":{"essentialExpense":4200000},"initialAmount":0,"#
    + #""inBudget":true,"createdAt":"2026-10-01T00:00:00Z","updatedAt":"2026-10-01T00:00:00Z"}"#
private let goalDetailJSON =
    #"{"id":"e","kind":"emergency_fund","name":"Dana Darurat","targetAmount":25200000,"targetDate":"2029-04-25","#
    + #""monthlyDeposit":650000,"savedAmount":4800000,"inputs":{"essentialExpense":4200000},"initialAmount":0,"#
    + #""inBudget":true,"createdAt":"2026-10-01T00:00:00Z","updatedAt":"2026-10-01T00:00:00Z","#
    + #""deposits":[{"id":"d1","amount":600000,"depositedOn":"2026-09-25"}],"#
    + #""milestones":[{"key":"one_week","amount":980000,"reachedOn":"2026-03-25"},"#
    + #"{"key":"target","amount":25200000,"reachedOn":null}]}"#
private let planJSON =
    #"{"ladder":[{"step":1,"key":"pay_off_debt","status":"current","detail":{"debtName":"Paylater A"}},"#
    + #"{"step":2,"key":"emergency_fund","status":"todo","detail":{"multiple":1.1,"targetMultiple":6}},"#
    + #"{"step":3,"key":"protection","status":"done","detail":{"health":true,"incomeCover":false}},"#
    + #"{"step":4,"key":"invest","status":"todo","detail":{}}],"goals":[\#(summaryJSON)],"riskProfile":"moderate","#
    + #""prefill":{"essentialExpense":4200000,"emergencyFund":4800000,"married":true,"dependants":0,"#
    + #""monthlyIncome":7500000}}"#
