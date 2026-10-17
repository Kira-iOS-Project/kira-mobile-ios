import APIClient
import Domain
import Observation

/**
 Riwayat Kira Score (SKR-07 6 Bulan, SKR-07b 1 Tahun): the score now, one bar per month and what
 changed this month. 6 Bulan or 1 Tahun switches the range; a range already loaded shows at once,
 the other loads while the last one stays on screen, and an answer for a range no longer chosen is
 kept for later but never shown over the chosen one.
 */
@MainActor
@Observable
package final class ScoreHistoryModel {
    /** The range on screen. */
    package private(set) var range: ScoreHistoryRange = .sixMonths
    /** Empty before the health check. */
    package private(set) var phase: ScreenPhase<ScoreHistory> = .loading
    /** Whether the chosen range is loading while another one is on screen. */
    package private(set) var isSwitching = false

    private let service: any ScoreService
    private var loaded: [ScoreHistoryRange: ScoreHistory] = [:]

    /** A model that loads through `service`. */
    package init(service: any ScoreService) {
        self.service = service
    }

    /** Loads the chosen range, or Coba Lagi after a failure. */
    package func load() async {
        if phase.value == nil { phase = .loading }
        await fetch(range)
    }

    /** 6 Bulan or 1 Tahun. */
    package func select(_ range: ScoreHistoryRange) async {
        guard range != self.range else { return }
        self.range = range
        if let history = loaded[range] {
            phase = .loaded(history)
            isSwitching = false
            return
        }
        isSwitching = phase.value != nil
        defer { if self.range == range { isSwitching = false } }
        await fetch(range)
    }

    private func fetch(_ requested: ScoreHistoryRange) async {
        let result: ScreenPhase<ScoreHistory>
        do {
            if let history = try await service.history(requested) {
                loaded[requested] = history
                result = .loaded(history)
            } else {
                result = .empty
            }
        } catch {
            result = .failed(AppProblem(error))
        }
        if range == requested { phase = result }
    }
}
