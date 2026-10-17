/**
 SKR-07, Riwayat Kira Score, for `ScreenLaunch`: the board's six months (the UI test taps 1 Tahun for
 SKR-07b), under a month of data, before the health check, a history that failed to load, and
 one outside Kira Plus (PLAN_FEATURE_UNAVAILABLE).
 */
#if DEBUG
    import APIClient
    import Domain
    import Features
    import SwiftUI

    struct ScoreHistoryLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                ScoreHistoryScreen(service: service) { _ in }
            }
        }

        private var service: any ScoreService {
            switch screen {
            case .scoreHistoryShort: StubScoreHistoryService(history: .oneMonth)
            case .scoreHistoryEmpty: StubScoreHistoryService(history: nil)
            case .scoreHistoryFailed: StubScoreHistoryService(problem: AppProblem.connectionLost)
            case .scoreHistoryLocked: StubScoreHistoryService(problem: AppProblem(code: "PLAN_FEATURE_UNAVAILABLE"))
            default: PreviewScoreService()
            }
        }
    }
#endif
