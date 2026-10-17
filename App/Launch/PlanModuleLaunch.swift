/**
 REN-08's modules for `ScreenLaunch`: Modul Belajar of each asset class, on its first drawn part.
 */
#if DEBUG
    import Domain
    import SwiftUI

    struct PlanModuleLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack { AssetModuleScreen(assetClass: assetClass) { _ in } }
        }

        private var assetClass: RiskAssetClass {
            switch screen {
            case .moduleGovernmentBonds: .governmentBonds
            case .moduleDeposits: .deposits
            case .moduleGold: .gold
            case .moduleStocks: .stocks
            case .moduleCrypto: .crypto
            default: .moneyMarketFund
            }
        }
    }
#endif
