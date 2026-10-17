import APIClient
import Domain
import Observation

/**
 Portofolio Manual (REN-10): the total, the composition by class, each asset with its share, and
 the indicator the assets feed. The eye hides every amount, as on Beranda. The screen loads again
 each time it shows, so an asset added or updated in Tambah Aset is there on the way back.
 */
@MainActor
@Observable
package final class PortfolioModel {
    /** The portfolio; empty when no asset is kept yet. */
    package private(set) var phase: ScreenPhase<Portfolio> = .loading
    /** Whether the amounts are hidden. */
    package private(set) var isMasked: Bool

    private let service: any PortfolioService

    /** The portfolio through `service`, its amounts hidden from the start when `isMasked`. */
    package init(service: any PortfolioService, isMasked: Bool = false) {
        self.service = service
        self.isMasked = isMasked
    }

    /** Loads the portfolio; a reload keeps what is on screen until the answer comes. */
    package func load() async {
        do {
            let portfolio = try await service.portfolio()
            phase = portfolio.assets.isEmpty ? .empty : .loaded(portfolio)
        } catch {
            if phase.value == nil { phase = .failed(AppProblem(error)) }
        }
    }

    /** The eye: hides or shows every amount. */
    package func toggleMasked() {
        isMasked.toggle()
    }

    /** Each asset's whole percentage of the total, by id. */
    package var assetShares: [String: Int] {
        PortfolioShares.byAsset(phase.value?.assets ?? [])
    }

    /** The composition bar: each class with its whole percentage. */
    package var classShares: [ClassShare] {
        PortfolioShares.byClass(phase.value?.assets ?? [])
    }
}
