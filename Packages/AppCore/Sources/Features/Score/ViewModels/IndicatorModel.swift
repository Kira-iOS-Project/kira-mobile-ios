import APIClient
import Domain
import Observation

/** Detail Indikator (SKR-02, SKR-02b to SKR-02f): one indicator, its ladder and the next rung. */
@MainActor
@Observable
package final class IndicatorModel {
    /** The indicator the screen shows. */
    package let key: IndicatorKey
    /** The detail, loading until the API answers. */
    package private(set) var phase: ScreenPhase<IndicatorDetail> = .loading
    /**
     Whether the plan includes Portofolio Manual; read only for Utang terhadap Aset, and taken as
     true when it cannot be read, since Portofolio then says itself that the plan lacks it.
     */
    package private(set) var includesPortfolio = true

    private let service: any ScoreService

    /** A model of indicator `key`, loaded through `service`. */
    package init(key: IndicatorKey, service: any ScoreService) {
        self.key = key
        self.service = service
    }

    /** Loads the indicator. */
    package func load() async {
        if key == .debtToAsset { includesPortfolio = (try? await service.planIncludesPortfolio()) ?? true }
        do {
            phase = .loaded(try await service.indicator(key))
        } catch {
            phase = .failed(AppProblem(error))
        }
    }

    /**
     The next-rung card's primary button: the key's route, except that Utang terhadap Aset opens
     Paket Kira on a plan without Portofolio Manual, as Riwayat's import does.
     */
    package var nextRungRoute: AppRoute {
        key == .debtToAsset && !includesPortfolio ? .plans(yearly: false) : key.nextRungRoute
    }
}
