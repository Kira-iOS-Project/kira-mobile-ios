import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** The board's Dana Darurat, with its deposits and milestones; deposits are recorded or fail as set. */
/** Shared with GoalDetailModelDefaultsTests. */
actor DetailStub: GoalService {
    static let goal = GoalDetail(
        summary: GoalSummary(
            id: "emergency", kind: .emergencyFund, name: "Dana Darurat", targetAmount: 25_200_000,
            targetDate: CalendarDay(year: 2029, month: 4, day: 25), monthlyDeposit: 650_000, savedAmount: 4_800_000),
        deposits: [
            GoalDeposit(id: "d2", amount: 600_000, depositedOn: CalendarDay(year: 2026, month: 9, day: 25)),
            GoalDeposit(id: "d1", amount: 500_000, depositedOn: CalendarDay(year: 2026, month: 8, day: 25)),
        ],
        milestones: [
            GoalMilestone(key: .oneWeek, amount: 980_000, reachedOn: CalendarDay(year: 2026, month: 3, day: 25)),
            GoalMilestone(key: .oneMonth, amount: 4_200_000, reachedOn: CalendarDay(year: 2026, month: 9, day: 25)),
            GoalMilestone(key: .threeMonths, amount: 12_600_000, reachedOn: nil),
            GoalMilestone(key: .target, amount: 25_200_000, reachedOn: nil),
        ])

    var goalAnswer: Result<GoalDetail, AppProblem> = .success(goal)
    var depositFailures: [any Error] = []
    private(set) var sent: [GoalDeposit] = []
    private(set) var goalCalls = 0

    func configure(_ change: @Sendable (isolated DetailStub) -> Void) { change(self) }

    func plan() throws -> PlanOverview { throw AppProblem() }
    func goal(id _: String) throws -> GoalDetail {
        goalCalls += 1
        return try goalAnswer.get()
    }
    func createGoal(_: GoalDraft) throws -> GoalDetail { throw AppProblem() }
    func updateGoal(id _: String, _: GoalDraft) throws -> GoalDetail { throw AppProblem() }
    func deleteGoal(id _: String) throws { throw AppProblem() }
    func addDeposit(goalId _: String, amount: Int, depositedOn: CalendarDay, depositId: String) throws -> GoalDeposit {
        sent.append(GoalDeposit(id: depositId, amount: amount, depositedOn: depositedOn))
        if !depositFailures.isEmpty { throw depositFailures.removeFirst() }
        return GoalDeposit(id: depositId, amount: amount, depositedOn: depositedOn)
    }
}

/** Hands out "id-1", "id-2", … in order. */
private final class Ids: @unchecked Sendable {
    private var next = 0
    func make() -> String {
        next += 1
        return "id-\(next)"
    }
}

@MainActor
@Suite("GoalDetailModel")
struct GoalDetailModelTests {
    /** 17 Oktober 2026, 10.00 WIB. */
    nonisolated private static let now = Date(timeIntervalSince1970: 1_792_206_000)

    private func model(_ stub: DetailStub, ids: Ids = Ids()) -> GoalDetailModel {
        GoalDetailModel(id: "emergency", service: stub, now: { Self.now }, makeId: { ids.make() })
    }

    @Test("shows progress, the next milestone with its shortfall, the milestone reached last, and 6×")
    func loads() async {
        let model = model(DetailStub())
        #expect(model.progress == 0 && model.nextMilestone == nil && model.latestReached == nil)
        #expect(model.targetMultiple == nil && model.nextDeposit == nil)
        await model.load()
        #expect(abs(model.progress - 4_800_000.0 / 25_200_000) < 0.0001)
        #expect(model.nextMilestone?.milestone.key == .threeMonths && model.nextMilestone?.shortfall == 7_800_000)
        #expect(model.latestReached?.key == .oneMonth)
        #expect(model.targetMultiple == 6)
    }

    @Test("the next deposit falls on the last one's day: this month, or next when it has passed")
    func nextDeposit() async {
        let model = model(DetailStub())
        await model.load()
        #expect(model.nextDeposit?.day == CalendarDay(year: 2026, month: 10, day: 25))
        #expect(model.nextDeposit?.dayOfMonth == 25)
        let late = GoalDetailModel(
            id: "e", service: DetailStub(), now: { Self.now.addingTimeInterval(10 * 86_400) }, makeId: { "x" })
        await late.load()
        #expect(late.nextDeposit?.day == CalendarDay(year: 2026, month: 11, day: 25))
    }

    @Test("a goal that is gone is empty; another failure, or a lost connection, fails")
    func failures() async {
        let gone = DetailStub()
        await gone.configure { $0.goalAnswer = .failure(AppProblem(code: "GOAL_NOT_FOUND")) }
        let goneModel = model(gone)
        await goneModel.load()
        guard case .empty = goneModel.phase else { return #expect(Bool(false)) }
        let refused = DetailStub()
        await refused.configure { $0.goalAnswer = .failure(AppProblem(code: "AUTH_UNAUTHENTICATED")) }
        let refusedModel = model(refused)
        await refusedModel.load()
        guard case .failed(let problem) = refusedModel.phase else { return #expect(Bool(false)) }
        #expect(problem.knownCode == .authUnauthenticated)
    }

    @Test("a milestone-less goal has no multiple; an empty target makes no progress")
    func noMilestones() async {
        let stub = DetailStub()
        let plain = GoalDetail(
            summary: GoalSummary(
                id: "g", kind: .goods, name: "Laptop", targetAmount: 0,
                targetDate: CalendarDay(year: 2027, month: 1, day: 1), monthlyDeposit: 0, savedAmount: 0))
        await stub.configure { $0.goalAnswer = .success(plain) }
        let model = model(stub)
        await model.load()
        #expect(model.targetMultiple == nil && model.progress == 0 && model.nextMilestone == nil)
    }

    @Test("Tambah Setoran opens on the monthly deposit; an empty amount stays inline and sends nothing")
    func depositValidation() async {
        let stub = DetailStub()
        let model = model(stub)
        model.openDeposit()
        #expect(model.depositAmount.isEmpty && model.deposit.isOpen)
        await model.load()
        model.openDeposit()
        #expect(model.depositAmount == "650000")
        model.depositAmount = ""
        await model.submitDeposit()
        #expect(model.isDepositAmountMissing && model.deposit.isOpen)
        #expect(await stub.sent.isEmpty)
    }

    @Test("a saved deposit closes the sheet, shows Setoran Tersimpan and reloads the goal")
    func depositSaved() async {
        let stub = DetailStub()
        let model = model(stub)
        await model.load()
        model.openDeposit()
        model.depositAmount = "700.000"
        await model.submitDeposit()
        #expect(!model.deposit.isOpen && model.showsDepositSaved && !model.isDepositAmountMissing)
        let sent = await stub.sent
        #expect(sent.map(\.amount) == [700_000] && sent.map(\.id) == ["id-1"])
        #expect(sent.first?.depositedOn == CalendarDay(year: 2026, month: 10, day: 17))
        #expect(await stub.goalCalls == 2)
    }

    @Test("a failed deposit closes into the dialog; Coba Lagi sends the same key, a new one after a conflict")
    func depositRetry() async {
        let stub = DetailStub()
        await stub.configure {
            $0.depositFailures = [URLError(.notConnectedToInternet), AppProblem(code: "GOAL_DEPOSIT_CONFLICT")]
        }
        let model = model(stub)
        await model.load()
        model.openDeposit()
        await model.submitDeposit()
        #expect(!model.deposit.isOpen && model.deposit.failure?.isConnectionLoss == true)
        model.deposit.open()
        await model.submitDeposit()
        #expect(model.deposit.failure?.knownCode == .goalDepositConflict)
        model.deposit.open()
        await model.submitDeposit()
        #expect(model.showsDepositSaved)
        #expect(await stub.sent.map(\.id) == ["id-1", "id-1", "id-2"])
    }
}
