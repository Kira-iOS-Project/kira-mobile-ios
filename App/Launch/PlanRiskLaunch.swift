/**
 REN-06 to REN-07 and REN-09 for `ScreenLaunch`, on the preview services: the quiz fresh on its
 first question (ladder notice shown), with the plan unreadable (notice hidden, the board's ranges),
 each later question with the boards' persona answered up to it, the persona's Lihat Hasil failing
 once (the test taps it for the failure dialog, then Coba Lagi), Hasil Kuis for each profile, and Cek
 Legalitas. Pushed routes land here, so the tests can follow a link; Kira Peduli and the modules
 stay empty.
 */
#if DEBUG
    import Domain
    import Features
    import SwiftUI

    struct PlanRiskLaunch: View {
        let screen: LaunchScreen
        @State private var path: [AppRoute] = []

        var body: some View {
            NavigationStack(path: $path) {
                root.navigationDestination(for: AppRoute.self) { route in
                    if route == .legalityCheck {
                        LegalityCheckScreen(service: PreviewLegalityService(), onOpen: open)
                    } else {
                        EmptySlot()
                    }
                }
            }
        }

        @ViewBuilder private var root: some View {
            switch screen {
            case .legalityCheck: LegalityCheckScreen(service: PreviewLegalityService(), onOpen: open)
            case .riskQuizUnreadablePlan: quiz(plans: UnreadablePlanService())
            case .riskDrawdown: quiz(.quiz(.drawdown), answered: 1)
            case .riskHorizon: quiz(.quiz(.horizon), answered: 2)
            case .riskExperience: quiz(.quiz(.experience), answered: 3)
            case .riskDeposit: quiz(.quiz(.monthlyDeposit), answered: 5)
            case .riskSaveFailing:
                quiz(.quiz(.monthlyDeposit), answered: 5, service: PreviewRiskProfileService(failedSaves: 1))
            case .riskResult: result(.moderate)
            case .riskResultConservative: result(.conservative)
            case .riskResultAggressive: result(.aggressive)
            default: quiz()
            }
        }

        private func open(_ route: AppRoute) { path.append(route) }

        private func quiz(
            _ start: RiskQuizModel.Start = .quiz(), answered: Int = 0,
            service: any RiskProfileService = PreviewRiskProfileService(), plans: any GoalService = PreviewGoalService()
        ) -> some View {
            let draft = RiskQuizDraft(answers: RiskAnswers(Array(PreviewRiskProfileService.persona.prefix(answered))))
            return RiskQuizScreen(
                model: RiskQuizModel(service: service, draft: draft, plans: plans, start: start), onOpen: open)
        }

        private func result(_ profile: RiskProfile) -> some View {
            quiz(.savedResult, service: PreviewRiskProfileService(saved: PreviewRiskProfileService.saved(profile)))
        }
    }
#endif
