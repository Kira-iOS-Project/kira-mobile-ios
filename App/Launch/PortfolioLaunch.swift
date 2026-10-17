/**
 REN-10 and REN-11, Portofolio Manual and Tambah Aset, for `ScreenLaunch`: the board's three assets
 (also masked, empty, and failed to load), Tambah Aset (also with a save that fails, for its dialog),
 and the form updating the gold. The UI tests reach Aset Tersimpan (REN-11b) by saving the form.
 */
#if DEBUG
    import SwiftUI

    struct PortfolioLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                switch screen {
                case .portfolioMasked: PortfolioScreen(service: PreviewPortfolioService(), startsMasked: true) { _ in }
                case .portfolioEmpty: PortfolioScreen(service: PreviewPortfolioService(assets: [])) { _ in }
                case .portfolioFailed: PortfolioScreen(service: PreviewPortfolioService(failsLoad: true)) { _ in }
                case .addAsset: AssetFormScreen(service: PreviewPortfolioService())
                case .addAssetFailing: AssetFormScreen(service: PreviewPortfolioService(failsSave: true))
                case .editAsset: AssetFormScreen(service: PreviewPortfolioService(), assetId: "gold")
                default: PortfolioScreen(service: PreviewPortfolioService()) { _ in }
                }
            }
        }
    }
#endif
