/**
 Where each area's entry view plugs into the shell: onboarding, Beranda and every pushed route
 (RouteSlot). Catat and Riwayat (RecordSlot and the record routes) stay empty for their own
 integration. Each slot takes its services from the environment.
 */
import Features
import SwiftUI

/** ONB-02 to ONB-14: onboarding and sign-in, from the intro or where the account left it. */
struct OnboardingSlot: View {
    let start: OnboardingStart
    let onFinished: (OnboardingOutcome) -> Void
    @Environment(\.appServices) private var services
    @State private var legal: LegalLink?

    var body: some View {
        OnboardingFlow(service: services.onboarding, pinSetup: services.pinSetup, start: start, onFinished: onFinished) {
            legal = LegalLink(route: $0)
        }
        .fullScreenCover(item: $legal) { link in LegalCover(first: link.route) }
    }
}

/** BRD-01 to BRD-03: Beranda, the home tab's root. */
struct HomeSlot: View {
    let onOpen: (AppRoute) -> Void
    @Environment(\.appServices) private var services

    var body: some View {
        HomeScreen(service: services.home, onOpen: onOpen)
    }
}

/** CAT-01: Catat, the record section's root; its integration plugs in here. */
struct RecordSlot: View {
    let onOpen: (AppRoute) -> Void

    var body: some View { EmptySlot() }
}

/** The empty surface of a slot whose area is not plugged in yet. */
struct EmptySlot: View {

    var body: some View {
        Color.surface
            .ignoresSafeArea()
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityHidden(true)
    }
}

/** A Terms or Privacy Policy link from onboarding, before the tabs exist. */
private struct LegalLink: Identifiable {
    let route: AppRoute
    var id: AppRoute { route }
}

/**
 The Terms or the Privacy Policy over onboarding, with the documents they link to (Layanan
 Pengaduan); their back button on the first one closes the cover.
 */
private struct LegalCover: View {
    let first: AppRoute
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            LegalScreen(route: first, onOpen: open)
                .navigationDestination(for: AppRoute.self) { route in LegalScreen(route: route, onOpen: open) }
        }
    }
}

extension LegalCover {
    /** Only the documents open here; Kira Peduli and the rest wait for the tabs. */
    private func open(_ route: AppRoute) {
        switch route {
        case .about, .terms, .privacyPolicy, .complaints: path.append(route)
        default: break
        }
    }
}

/** One of the documents of Tentang Kira. */
struct LegalScreen: View {
    let route: AppRoute
    let onOpen: (AppRoute) -> Void

    var body: some View {
        switch route {
        case .terms: TermsScreen()
        case .privacyPolicy: PrivacyPolicyScreen(onOpen: onOpen)
        case .complaints: ComplaintsScreen()
        default: AboutScreen(onOpen: onOpen)
        }
    }
}
