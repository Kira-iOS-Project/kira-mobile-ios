/**
 Where the history flow hands navigation back to the app: the places it links to that it does not
 own. `RecordRoute` maps each to an `AppRoute` (the help button
 to Kira Peduli, `AppRoute.care`).
 */
enum HistoryDestination: Hashable {
    /** The help button: Kira Peduli. */
    case help
}
