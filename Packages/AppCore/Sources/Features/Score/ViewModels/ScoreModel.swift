import APIClient
import Domain
import Observation

/** Kira Score (SKR-01, SKR-01b): the score, its formula, the steps and the six indicators. */
@MainActor
@Observable
package final class ScoreModel {
    /** Empty before the health check. */
    package private(set) var phase: ScreenPhase<ScoreReport> = .loading

    private let service: any ScoreService

    /** A model that loads through `service`. */
    package init(service: any ScoreService) {
        self.service = service
    }

    /** Loads the score. */
    package func load() async {
        do {
            phase = try await service.score().map { .loaded($0) } ?? .empty
        } catch {
            phase = .failed(AppProblem(error))
        }
    }
}
