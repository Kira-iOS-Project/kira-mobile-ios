/**
 The screen of each pushed route, by area: Score (score, indicator), Account (profile … deleteAccount,
 about … complaints), Plans (plans … scholarshipStatus). "Cek Ulang" (`healthCheck`) covers the
 shell instead (MainShell); Komunitas (`community`) is the dock's own section; Catat's and
 Riwayat's routes stay empty for their own integration, and an unavailable area never gets here.
 */
import Features
import SwiftUI

struct RouteSlot: View {
    let route: AppRoute
    let onOpen: (AppRoute) -> Void
    @Environment(\.appServices) private var services
    @Environment(\.endSession) private var endSession

    var body: some View {
        switch route {
        case .score: ScoreScreen(service: services.score, onOpen: onOpen)
        case .indicator(let key): IndicatorScreen(key: key, service: services.score, onOpen: onOpen)
        case .profile:
            ProfileScreen(
                service: services.account, settings: services.security, onOpen: onOpen, onSignedOut: { endSession() })
        case .security, .changePin:
            SecurityScreen(service: services.account, settings: services.security, onOpen: onOpen)
        case .privacy, .deleteAccount:
            PrivacyScreen(
                service: services.account, settings: services.security, onOpen: onOpen, onSignedOut: { endSession() })
        case .about, .terms, .privacyPolicy, .complaints: LegalScreen(route: route, onOpen: onOpen)
        case .plans, .planDetail, .checkout, .subscription, .paymentMethod, .invoices, .treat, .scholarship,
            .scholarshipApply, .scholarshipStatus:
            PlansRoute(route: route, service: services.plans, onOpen: onOpen)
        case .communityGroup(let id): GroupDetailScreen(groupID: id, service: services.community, onOpen: onOpen)
        case .marketplace, .product, .submitProduct: EmptySlot()
        case .home, .record, .community, .healthCheck, .recordManual, .receiptScan, .voiceInput, .history, .transaction,
            .conversation, .importStatement, .unavailable:
            EmptySlot()
        }
    }
}
