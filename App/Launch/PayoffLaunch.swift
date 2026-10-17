/**
 SKR's Rencana Pelunasan for `ScreenLaunch`, on the preview services: the board as drawn (SKR-03),
 with "Gimana Ngitungnya?" open (SKR-03b, RencanaPelunasanTerbuka), and on Avalanche (SKR-03c,
 RencanaPelunasanAvalanche).
 */
#if DEBUG
    import Domain
    import SwiftUI

    struct PayoffLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                PayoffScreen(
                    service: PreviewPayoffService(), plans: PreviewPayoffPlanService(),
                    method: screen == .payoffAvalanche ? .avalanche : .snowball, showsHow: screen == .payoffHow
                ) { _ in }
            }
        }
    }
#endif
