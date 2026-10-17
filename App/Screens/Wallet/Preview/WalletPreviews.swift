import SwiftUI

#if DEBUG
    #Preview("Dompet") {
        NavigationStack {
            WalletsScreen(service: PreviewWalletService(), onOpenDebt: { _ in }, onOpenHelp: {})
        }
    }

    #Preview("Detail Utang") {
        NavigationStack {
            DebtDetailScreen(id: "paylater-a", service: PreviewWalletService())
        }
    }
#endif
