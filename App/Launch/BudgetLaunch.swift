/** UNG-04 Budget for `ScreenLaunch`: the current pay period on the preview service, or a load that fails. */
#if DEBUG
    import SwiftUI

    struct BudgetLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                BudgetScreen(service: PreviewBudgetService(isFailing: screen == .budgetFailed)) { _ in }
            }
        }
    }
#endif
