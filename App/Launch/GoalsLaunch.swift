/**
 Rencana's goal forms for `ScreenLaunch`, filled in with their boards' figures (TujuanKendaraan,
 TujuanBarang, TujuanLainnya); the UI tests tap Hitung for each Hasil Simulasi.
 */
#if DEBUG
    import Features
    import SwiftUI

    struct GoalsLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                switch screen {
                case .goalGoods:
                    PriceGoalScreen(
                        model: PriceGoalModel(kind: .goods, horizon: .months, values: GoalSamples.goods),
                        onOpen: { _ in })
                case .goalOther: OtherGoalScreen(model: OtherGoalModel(values: GoalSamples.other), onOpen: { _ in })
                default:
                    PriceGoalScreen(
                        model: PriceGoalModel(kind: .vehicle, horizon: .years, values: GoalSamples.vehicle),
                        onOpen: { _ in })
                }
            }
        }
    }
#endif
