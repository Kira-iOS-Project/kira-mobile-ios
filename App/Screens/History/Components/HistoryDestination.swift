/**
 Where the history flow hands navigation back to the app: the places it links to that it does not
 own. `RecordRoute` maps each to an `AppRoute` (the help button to Kira Peduli, `AppRoute.care`;
 Impor Mutasi on a plan without it to the plans, `AppRoute.plans`).
 */
enum HistoryDestination: Hashable {
    /** The help button: Kira Peduli. */
    case help
    /** Impor Mutasi on a plan without it: Paket Kira, as the microphone does for voice. */
    case plans
}
