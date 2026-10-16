/**
 Where the history flow hands navigation back to the app: the places it links to that it does not
 own. The integrator maps each to an `AppRoute` (Kira Peduli is `AppRoute.unavailable(.care)` until
 that area is built).
 */
enum HistoryDestination: Hashable {
    /** The help button: Kira Peduli. */
    case help
}
