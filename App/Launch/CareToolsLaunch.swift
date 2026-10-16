/**
 Kira Peduli's tools for `ScreenLaunch`: Naskah Pengajuan Keringanan on the canvas's sample. The UI
 test opens the lender list (09b), a phrase's sheet and Naskah Disalin (09c) from the screen.
 */
#if DEBUG
    import SwiftUI

    struct CareToolsLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                NegotiationScriptScreen(service: PreviewCareToolsService()) { _ in }
            }
        }
    }
#endif
