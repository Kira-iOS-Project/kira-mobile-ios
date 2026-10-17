/**
 UNG-02 and UNG-02b, Tambah Dompet and Dompet Ditambahkan, for `ScreenLaunch`: Dompet with the sheet
 open, and with a save that fails, for its failure dialog. The UI tests reach Dompet Ditambahkan by
 saving the sheet.
 */
#if DEBUG
    import APIClient
    import Domain
    import Features
    import SwiftUI

    struct WalletAddLaunch: View {
        let screen: LaunchScreen

        private var service: any WalletService {
            screen == .walletAddFailing ? FailingWalletService() : PreviewWalletService()
        }

        var body: some View {
            NavigationStack {
                WalletsScreen(service: service, onOpenDebt: { _ in }, onOpenHelp: {}, startsAdding: true)
            }
        }
    }

    /** Dompet on the preview's accounts, whose new wallet never saves (offline). */
    private struct FailingWalletService: WalletService {
        func overview() async throws -> WalletOverview { try await PreviewWalletService().overview() }
        func addWallet(_: WalletDraft) throws { throw AppProblem.connectionLost }
    }
#endif
