import APIClient
import Observation

/**
 What a pushed route has to fetch before its screen can show, such as a plan's terms for its
 detail or the current payment method: loading, then the value, nothing (`empty`) or the problem.
 */
@MainActor @Observable
package final class RouteLoadModel<Value: Sendable> {
    /** Loading, loaded, empty or failed. */
    package private(set) var phase = ScreenPhase<Value>.loading
    @ObservationIgnored private let fetch: @Sendable () async throws -> Value?
    @ObservationIgnored private var hasStarted = false

    /** A model that fetches with `fetch`; nil means there is nothing to show. */
    package init(fetch: @escaping @Sendable () async throws -> Value?) {
        self.fetch = fetch
    }

    /** Fetches the first time the screen shows; coming back to it keeps what it loaded. */
    package func loadIfNeeded() async {
        guard !hasStarted else { return }
        hasStarted = true
        await load()
    }

    /** Fetches, or fetches again after a failure. */
    package func load() async {
        phase = .loading
        do {
            if let value = try await fetch() {
                phase = .loaded(value)
            } else {
                phase = .empty
            }
        } catch {
            phase = .failed(AppProblem(error))
        }
    }
}
