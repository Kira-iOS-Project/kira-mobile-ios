import APIClient
import Domain
import Observation

/**
 UNG-03 Detail Utang (board DetailUtang): one debt account, loaded once. A failed load shows its
 problem with Coba Lagi; a debt that is gone (404) shows the same, worded as such.
 */
@MainActor
@Observable
package final class DebtDetailModel {
    /** The debt once loaded. */
    package private(set) var phase: ScreenPhase<DebtDetail> = .loading

    private let id: String
    private let service: any DebtDetailService

    /** Debt `id`, read through `service`. */
    package init(id: String, service: any DebtDetailService) {
        self.id = id
        self.service = service
    }

    /** Loads the debt; Coba Lagi calls it again. */
    package func load() async {
        do {
            phase = .loaded(try await service.debt(id: id))
        } catch {
            phase = .failed(AppProblem(error))
        }
    }
}
