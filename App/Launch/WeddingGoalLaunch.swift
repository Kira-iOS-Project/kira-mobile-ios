/**
 REN-02d and REN-04e, Tujuan Baru · Menikah and its Hasil Simulasi, for `ScreenLaunch`, on the
 board's persona (Standar, 2 years): the form, and its result, Hampir Cocok with three
 recommendations.
 */
#if DEBUG
    import Domain
    import Features
    import SwiftUI

    struct WeddingGoalLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                if screen == .weddingGoalResult, let goal = WeddingFormModel.sample().result {
                    WeddingResultScreen(goal: goal, preset: .standard, service: PreviewGoalService()) { _ in }
                } else {
                    WeddingFormScreen(service: PreviewGoalService(), model: .sample()) { _ in }
                }
            }
        }
    }
#endif
