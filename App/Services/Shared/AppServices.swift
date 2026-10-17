/**
 Every service the screens call, built once by the composition root (AGENTS.md Rule 1) and handed
 down through the environment. `live` calls the API through the generated client; `preview`
 answers with the canvas's sample data, for previews and for a debug build launched with
 `-KiraPreviewServices`.
 */
import APIClient
import Features
import SwiftUI

struct AppServices {
    let onboarding: any OnboardingService
    let pinSetup: any PinSetup
    let account: any AccountService
    let security: any SecuritySettings
    let plans: any PlansService
    let home: any HomeService
    let score: any ScoreService
    let recovery: any PinRecoveryService
    let community: any CommunityService
    let care: any CareService
    let careTools: any CareToolsService
    let debtEmergency: any DebtEmergencyService
    let marketplace: any MarketplaceService
    /** Rencana's plan and goals (`GET /plan`); nil until the live service lands with the plan's client. */
    let goals: (any GoalService)?
    /** REN-06 and REN-07; nil until the live service lands with the risk profile's client (B4). */
    let riskProfile: (any RiskProfileService)?
    /** The quiz's answers for the app's session (`RiskQuizDraft`). */
    let riskDraft: RiskQuizDraft
}

extension AppServices {
    /**
     The services over `api`. Signing in keeps the session in `session`; the PIN and the lock's
     settings stay with `lock` and `pins`, and every change of "Sembunyikan Saldo" reaches the lock.
     */
    static func live(api: KiraAPI, session: SessionStore, lock: AppLockModel, pins: PinStore) -> Self {
        let sync: HideBalancesSync = { [lock] hidden in lock.update { $0.hidesBalancesOnOpen = hidden } }
        return AppServices(
            onboarding: LiveOnboardingService(api: api, session: session, onHideBalances: sync),
            pinSetup: LockPinSetup(lock: lock),
            account: LiveAccountService(api: api, session: session, onHideBalances: sync),
            security: LiveSecuritySettings(lock: lock, pins: pins),
            plans: LivePlansService(api: api),
            home: LiveHomeService(api: api, onHideBalances: sync),
            score: LiveScoreService(api: api),
            recovery: LivePinRecoveryService(api: api),
            community: LiveCommunityService(api: api),
            care: LiveCareService(api: api),
            careTools: LiveCareToolsService(api: api),
            debtEmergency: LiveDebtEmergencyService(api: api),
            marketplace: LiveMarketplaceService(api: api),
            goals: nil, riskProfile: nil, riskDraft: RiskQuizDraft())
    }

    /** The canvas's sample data: nothing leaves the device. */
    static var preview: Self {
        AppServices(
            onboarding: PreviewOnboardingService(), pinSetup: PreviewPinSetup(), account: PreviewAccountService(),
            security: PreviewSecuritySettings(), plans: PreviewPlansService(), home: PreviewHomeService(),
            score: PreviewScoreService(), recovery: PreviewPinRecoveryService(),
            community: PreviewCommunityService(), care: PreviewCareService(), careTools: PreviewCareToolsService(),
            debtEmergency: PreviewDebtEmergencyService(), marketplace: PreviewMarketplaceService(),
            goals: PreviewGoalService(), riskProfile: PreviewRiskProfileService(), riskDraft: RiskQuizDraft())
    }
}

extension EnvironmentValues {
    /** The services the screens call; previews get the sample data. */
    @Entry var appServices = AppServices.preview
    /** Ends the session on this device: sign-out, a deleted account. */
    @Entry var endSession = EndSessionAction {}
}

/** Ends the session on this device, as `DismissAction` dismisses: call it like a function. */
struct EndSessionAction {
    let action: @MainActor () -> Void

    /** Ends the session. */
    @MainActor func callAsFunction() { action() }
}
