import APIClient

/**
 The one phase a screen model exposes (AGENTS.md Rule 4): loading, empty, loaded with its value,
 or failed with the API's problem.
 */
package enum ScreenPhase<Value: Sendable>: Sendable {
    case loading
    case empty
    case loaded(Value)
    case failed(AppProblem)

    /** The loaded value, or nil in every other phase. */
    package var value: Value? {
        if case .loaded(let value) = self { return value }
        return nil
    }
}
