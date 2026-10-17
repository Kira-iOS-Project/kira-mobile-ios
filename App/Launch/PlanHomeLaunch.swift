/**
 REN-01 and REN-05, Rencana and Detail Tujuan, for `ScreenLaunch`: the board's plan (also with no
 goal, and failed to load), the emergency fund's detail (also gone, and with a deposit that fails,
 for Tambah Setoran's failure dialog), on the preview service.
 */
#if DEBUG
    import APIClient
    import Domain
    import Features
    import SwiftUI

    struct PlanHomeLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                switch screen {
                case .planNoGoals: PlanScreen(service: PreviewGoalService(goals: [])) { _ in }
                case .planFailed: PlanScreen(service: FailingGoalService(fails: .plan)) { _ in }
                case .goalDetail: GoalDetailScreen(id: "emergency", service: PreviewGoalService()) { _ in }
                case .goalGone: GoalDetailScreen(id: "removed", service: FailingGoalService(fails: .goal)) { _ in }
                case .goalDepositFailing:
                    GoalDetailScreen(id: "emergency", service: FailingGoalService(fails: .deposit)) { _ in }
                default: PlanScreen(service: PreviewGoalService()) { _ in }
                }
            }
        }
    }

    /** The preview service with one call failing: the plan (offline), the goal (gone), or a deposit (offline). */
    private struct FailingGoalService: GoalService {
        enum Call { case plan, goal, deposit }

        let fails: Call
        private let preview = PreviewGoalService()

        func plan() async throws -> PlanOverview {
            if fails == .plan { throw AppProblem.connectionLost }
            return await preview.plan()
        }

        func goal(id: String) async throws -> GoalDetail {
            if fails == .goal { throw AppProblem(code: ProblemCode.goalNotFound.rawValue) }
            return await preview.goal(id: id)
        }

        func createGoal(_ draft: GoalDraft) async -> GoalDetail { await preview.createGoal(draft) }

        func updateGoal(id: String, _ draft: GoalDraft) async -> GoalDetail { await preview.updateGoal(id: id, draft) }

        func addDeposit(goalId _: String, amount _: Int, depositedOn _: CalendarDay, depositId _: String) throws
            -> GoalDeposit
        {
            throw AppProblem.connectionLost
        }
    }
#endif
