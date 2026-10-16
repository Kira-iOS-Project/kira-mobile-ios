import APIClient
import Domain
import Observation

/** Detail Indikator (SKR-02, SKR-02b to SKR-02f): one indicator, its ladder and the next rung. */
@MainActor
@Observable
package final class IndicatorModel {
    package let key: IndicatorKey
    package private(set) var phase: ScreenPhase<IndicatorDetail> = .loading

    private let service: any ScoreService

    package init(key: IndicatorKey, service: any ScoreService) {
        self.key = key
        self.service = service
    }

    /** Loads the indicator. */
    package func load() async {
        do {
            phase = .loaded(try await service.indicator(key))
        } catch {
            phase = .failed(error as? AppProblem ?? AppProblem())
        }
    }
}
