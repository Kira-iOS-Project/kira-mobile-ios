/**
 Where each area's entry view plugs into the shell. Every slot is an empty surface until the
 integrator replaces its body with the area's entry view (OnboardingFlow, HomeScreen, RecordScreen,
 ScoreScreen, HistoryScreen, the Account and Plans screens), passing `onOpen` for navigation out.
 No slot draws content of its own.
 */
import Features
import SwiftUI

/** ONB-02 to ONB-14: onboarding and sign-in. Calls `onFinished` once a session exists. */
struct OnboardingSlot: View {
    let onFinished: () -> Void

    var body: some View { EmptySlot() }
}

/** BRD-01 to BRD-03: Beranda, the home tab's root. */
struct HomeSlot: View {
    let onOpen: (AppRoute) -> Void

    var body: some View { EmptySlot() }
}

/** CAT-01: Catat, the record section's root, on the record service of `RecordComposition`. */
struct RecordSlot: View {
    let onOpen: (AppRoute) -> Void
    @Environment(\.recordComposition) private var composition

    var body: some View {
        if let record = (composition ?? .fallback)?.record {
            RecordScreen(service: record, onOpen: onOpen)
        } else {
            EmptySlot()
        }
    }
}

/** A pushed destination of any area, by its route (RouteDestination picks the area). */
struct RouteSlot: View {
    let route: AppRoute
    let onOpen: (AppRoute) -> Void

    var body: some View { EmptySlot() }
}

/** The empty surface a slot shows until its area plugs in. */
private struct EmptySlot: View {

    var body: some View {
        Color.surface
            .ignoresSafeArea()
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityHidden(true)
    }
}
