/**
 UNG-03 Detail Utang and SKR-06 Panduan SLIK for `ScreenLaunch`: Paylater A on the canvas's
 sample, a debt that is gone (404 `PAYOFF_DEBT_NOT_FOUND`), and the guide.
 */
#if DEBUG
    import APIClient
    import SwiftUI

    struct DebtDetailLaunch: View {
        let screen: LaunchScreen

        /** The debt is gone, or someone else's. */
        private let gone = AppProblem(code: "PAYOFF_DEBT_NOT_FOUND")

        var body: some View {
            NavigationStack {
                switch screen {
                case .debtDetailGone:
                    DebtDetailScreen(id: "gone", service: PreviewDebtDetailService(problem: gone)) { _ in }
                case .creditReportGuide: CreditReportGuideScreen { _ in }
                default: DebtDetailScreen(id: "paylater-a", service: PreviewDebtDetailService()) { _ in }
                }
            }
        }
    }
#endif
