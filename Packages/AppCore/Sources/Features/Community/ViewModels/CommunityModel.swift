import Domain
import Observation

/**
 Komunitas (KOM-01): the verified groups in the curators' order, filtered by a category chip
 ("Semua" shows all). The chips filter what was loaded, so switching costs no request.
 */
@MainActor @Observable
package final class CommunityModel {
    /** Loading, loaded, empty (no active group) or failed. */
    package private(set) var phase = ScreenPhase<CommunityDirectory>.loading
    /** The chip chosen; nil is "Semua". */
    package private(set) var category: CommunityCategory?
    private let service: any CommunityService

    /** A model loading through `service`. */
    package init(service: any CommunityService) {
        self.service = service
    }

    /** The groups the chosen chip shows, in the curators' order. */
    package var groups: [CommunityGroupSummary] {
        phase.value?.groups(in: category) ?? []
    }

    /** The chips after "Semua": the directory's categories. */
    package var categories: [CommunityCategory] {
        phase.value?.categories ?? []
    }

    /** Loads the directory, or again after a failure ("Coba Lagi"). */
    package func load() async {
        if phase.value == nil { phase = .loading }
        do {
            let directory = try await service.directory()
            phase = directory.groups.isEmpty ? .empty : .loaded(directory)
        } catch {
            if phase.value == nil { phase = .failed(CommunityFailure(error).screenProblem) }
        }
    }

    /** Taps a chip; nil is "Semua". */
    package func select(_ category: CommunityCategory?) {
        self.category = category
    }
}
