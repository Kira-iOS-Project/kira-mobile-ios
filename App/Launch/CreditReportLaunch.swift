/** SKR-06, Cek SLIK, for `ScreenLaunch`: the static guide as the shell pushes it. */
#if DEBUG
    import SwiftUI

    struct CreditReportLaunch: View {
        var body: some View {
            NavigationStack {
                CreditReportScreen { _ in }
            }
        }
    }
#endif
