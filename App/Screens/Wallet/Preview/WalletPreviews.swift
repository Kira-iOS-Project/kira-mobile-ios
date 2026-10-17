import SwiftUI

#if DEBUG
    #Preview("Dompet") {
        NavigationStack {
            WalletsScreen(service: PreviewWalletService(), onOpenDebt: { _ in }, onOpenHelp: {})
        }
    }
#endif
