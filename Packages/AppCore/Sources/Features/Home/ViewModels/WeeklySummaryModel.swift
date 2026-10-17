import APIClient
import Domain
import Observation

/**
 Ringkasan Mingguan (UNG-08): the week's total against the week before, the days and the largest
 categories; empty when nothing was spent this week, and Coba Lagi after a failed load.
 */
@MainActor
@Observable
package final class WeeklySummaryModel {
    /** The week, loading until the API answers. */
    package private(set) var phase: ScreenPhase<WeeklySummary> = .loading

    private let service: any WeeklySummaryService

    /** A model that loads through `service`. */
    package init(service: any WeeklySummaryService) {
        self.service = service
    }

    /** Loads the week, or loads it again after a failure. */
    package func load() async {
        if phase.value == nil { phase = .loading }
        do {
            let summary = try await service.weeklySummary()
            phase = summary.total > 0 ? .loaded(summary) : .empty
        } catch {
            phase = .failed(AppProblem(error))
        }
    }
}
