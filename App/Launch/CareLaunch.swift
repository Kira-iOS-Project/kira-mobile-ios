/**
 PED's help screens for `ScreenLaunch`: Kira Peduli (online and offline, where the shipped contacts
 stand in), its sheet over a chat, and Kirim Pesan ke Layanan Kira, with the sample Layanan Kira Peduli, and
 without it (`trustedMessageNoRecipient`), as production shows until its number exists.
 */
#if DEBUG
    import Features
    import SwiftUI

    struct CareLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                switch screen {
                case .careOffline: CareScreen(service: PreviewCareService(isOffline: true)) { _ in }
                case .careHelp: CareHelpLaunch()
                case .trustedMessage: TrustedMessageScreen(service: PreviewCareService())
                case .trustedMessageNoRecipient:
                    TrustedMessageScreen(service: PreviewCareService(listsKiraCare: false))
                default: CareScreen(service: PreviewCareService()) { _ in }
                }
            }
        }
    }

    /** The help sheet open over an empty surface; Kembali ke Chat leaves the surface showing. */
    private struct CareHelpLaunch: View {
        @State private var showsHelp = true

        var body: some View {
            Color.surface.ignoresSafeArea()
                .toolbar(.hidden, for: .navigationBar)
                .careHelpSheet(
                    isPresented: $showsHelp, service: PreviewCareService(), onOpen: { _ in }, onClose: {})
        }
    }
#endif
