import APIClient
import Domain
import Observation

/** Kira Score (SKR-01, SKR-01b): the score, its formula, the steps and the six indicators. */
@MainActor
@Observable
package final class ScoreModel {
    /** Empty before the health check. */
    package private(set) var phase: ScreenPhase<ScoreReport> = .loading
    /** Where "Lihat Riwayat Skor" leads: the history on Kira Plus, Paket Kira on any other plan. */
    package private(set) var historyRoute = AppRoute.scoreHistory

    private let service: any ScoreService

    /** A model that loads through `service`. */
    package init(service: any ScoreService) {
        self.service = service
    }

    /** Loads the score, and whether the plan includes its history. */
    package func load() async {
        async let includesHistory = service.includesHistory()
        do {
            phase = try await service.score().map { .loaded($0) } ?? .empty
        } catch {
            phase = .failed(AppProblem(error))
        }
        historyRoute = await includesHistory ? .scoreHistory : .plans(yearly: false)
    }
}
