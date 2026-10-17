/**
 UNG-01 Dompet for `ScreenLaunch`: the preview accounts, with the help button and the debt rows
 opening nothing.
 */
#if DEBUG
    import SwiftUI

    struct WalletsLaunch: View {
        var body: some View {
            NavigationStack {
                WalletsScreen(service: PreviewWalletService(), onOpenDebt: { _ in }, onOpenHelp: {})
            }
        }
    }
#endif
