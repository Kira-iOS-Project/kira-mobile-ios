import APIClient

/**
 The one phase a screen model exposes (AGENTS.md Rule 4): loading, empty, loaded with its value,
 or failed with the API's problem.
 */
package enum ScreenPhase<Value: Sendable>: Sendable {
    /** The first load is in flight. */
    case loading
    /** Loaded, with nothing to show. */
    case empty
    /** Loaded, with the screen's value. */
    case loaded(Value)
    /** The load failed with the API's problem. */
    case failed(AppProblem)

    /** The loaded value, or nil in every other phase. */
    package var value: Value? {
        if case .loaded(let value) = self { return value }
        return nil
    }
}
