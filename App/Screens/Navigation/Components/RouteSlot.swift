/**
 The screen of each pushed route, by area: Score (score, indicator), Account (profile … deleteAccount,
 about … complaints), Plans (plans … scholarshipStatus), Kira Peduli (care, trustedMessage; the PED
 screens of other branches keep a back button until they land). "Cek Ulang" (`healthCheck`) covers
 the shell instead (MainShell); Komunitas (`community`) is the dock's own section; Catat's and
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
        case .care: CareScreen(service: services.care, onOpen: onOpen)
        case .trustedMessage: TrustedMessageScreen(service: services.care)
        case .breathingExercise, .debtEmergency, .safetyPlan: PendingCareSlot()
        case .home, .record, .community, .healthCheck, .recordManual, .receiptScan, .voiceInput, .history, .transaction,
            .conversation, .importStatement, .unavailable:
            EmptySlot()
        }
    }
}

/**
 A Kira Peduli screen Kira Peduli links to before its own branch lands (PED-07, PED-10, PED-11): an
 empty surface that keeps the navigation bar, so its back button returns to Kira Peduli.
 */
private struct PendingCareSlot: View {
    var body: some View {
        Color.surface
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}
