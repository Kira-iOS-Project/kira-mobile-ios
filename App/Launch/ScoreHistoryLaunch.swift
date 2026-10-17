/**
 SKR-07, Riwayat Kira Score, for `ScreenLaunch`: the board's six months (the UI test taps 1 Tahun for
 SKR-07b), under a month of data, before the health check, and a history that failed to load.
 */
#if DEBUG
    import APIClient
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
            default: PreviewScoreService()
            }
        }
    }
#endif
