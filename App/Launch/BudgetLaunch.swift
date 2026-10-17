/** UNG-04 Budget for `ScreenLaunch`: the current pay period on the preview service. */
#if DEBUG
    import SwiftUI

    struct BudgetLaunch: View {
        var body: some View {
            NavigationStack {
                BudgetScreen(service: PreviewBudgetService()) { _ in } { _ in }
            }
        }
    }
#endif
