/**
 The Akun screens wired together for previews, as the root will wire them: a navigation stack
 that shows each AppRoute of this area and ignores the others. The integrator's RootView does the
 same with the real services.
 */
#if DEBUG
    import Features
    import SwiftUI

    /** Profil and every screen it opens, on sample data. */
    struct AccountPreviewFlow: View {
        @State private var path: [AppRoute]
        private let service = PreviewAccountService()
        private let settings = PreviewSecuritySettings()

        init(start: [AppRoute] = []) {
            path = start
        }

        var body: some View {
            NavigationStack(path: $path) {
                ProfileScreen(service: service, settings: settings, onOpen: open, onSignedOut: { path = [] })
                    .navigationDestination(for: AppRoute.self) { route in destination(route) }
            }
        }

        private func open(_ route: AppRoute) {
            if case .unavailable = route { return }
            path.append(route)
        }

        @ViewBuilder private func destination(_ route: AppRoute) -> some View {
            switch route {
            case .security: SecurityScreen(service: service, settings: settings, onOpen: open)
            case .privacy:
                PrivacyScreen(service: service, settings: settings, onOpen: open, onSignedOut: { path = [] })
            case .about: AboutScreen(onOpen: open)
            case .terms: TermsScreen()
            case .privacyPolicy: PrivacyPolicyScreen(onOpen: open)
            case .complaints: ComplaintsScreen()
            case .wallets: WalletsScreen(service: PreviewWalletService(), onOpenDebt: { _ in }, onOpenHelp: {})
            case .budget: BudgetScreen(service: PreviewBudgetService()) { _ in }
            default: EmptyView()
            }
        }
    }

    #Preview("Profil") { AccountPreviewFlow() }
    #Preview("Keamanan") { AccountPreviewFlow(start: [.security]) }
    #Preview("Data & Privasi") { AccountPreviewFlow(start: [.privacy]) }
    #Preview("Tentang Kira") { AccountPreviewFlow(start: [.about]) }
    #Preview("Syarat dan Ketentuan") { AccountPreviewFlow(start: [.about, .terms]) }
    #Preview("Kebijakan Privasi") { AccountPreviewFlow(start: [.about, .privacyPolicy]) }
    #Preview("Layanan Pengaduan") { AccountPreviewFlow(start: [.about, .complaints]) }
#endif
