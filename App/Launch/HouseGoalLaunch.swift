/**
 REN-02b and REN-04c, Tujuan Baru · DP Rumah and its Hasil Simulasi, for `ScreenLaunch`, on the
 board's persona: the form, the result, and the result whose Jadikan Pos Budget never gets an
 answer (the UI test taps it for the failure dialog).
 */
#if DEBUG
    import Features
    import SwiftUI

    struct HouseGoalLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                switch screen {
                case .houseGoalResult: result(PreviewGoalService())
                case .houseGoalBudgetFailing: result(UnansweredGoalService())
                default: HouseDownPaymentFormScreen(service: PreviewGoalService(), model: .sample()) { _ in }
                }
            }
        }

        @ViewBuilder private func result(_ service: any GoalService) -> some View {
            if let result = HouseDownPaymentFormModel.sample().result {
                HouseDownPaymentResultScreen(result: result, service: service) { _ in }
            }
        }
    }
#endif
