/**
 UNG-08, Ringkasan Mingguan, for `ScreenLaunch`: the board's week, a week without spending, and a
 week that failed to load (a lost connection).
 */
#if DEBUG
    import APIClient
    import Domain
    import Features
    import SwiftUI

    struct WeeklySummaryLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                WeeklySummaryScreen(service: service) { _ in }
            }
        }

        private var service: any WeeklySummaryService {
            switch screen {
            case .weeklySummaryEmpty: StubWeeklySummaryService(answer: .success(.quiet))
            case .weeklySummaryFailed: StubWeeklySummaryService(answer: .failure(.connectionLost))
            default: PreviewWeeklySummaryService()
            }
        }
    }

    /** A week the launch picks, or a problem. */
    private struct StubWeeklySummaryService: WeeklySummaryService {
        let answer: Result<WeeklySummary, AppProblem>

        func weeklySummary() throws -> WeeklySummary { try answer.get() }
    }

    extension WeeklySummary {
        /** The board's week with nothing spent. */
        fileprivate static let quiet = WeeklySummary(
            start: sample.start, end: sample.end, total: 0, previousTotal: 0,
            days: sample.days.map { DaySpending(day: $0.day, amount: 0) }, categories: [])
    }
#endif
