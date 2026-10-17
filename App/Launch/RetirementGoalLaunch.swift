/**
 REN's Dana Pensiun for `ScreenLaunch`: Tujuan Baru filled in as the board's persona (Rp6.000.000 a
 month, 28 → 55, Rp25.000.000 there, Rp2.000.000 a month at 10%), and its Hasil Simulasi.
 */
#if DEBUG
    import Domain
    import Features
    import SwiftUI

    struct RetirementGoalLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                if screen == .goalRetirementResult, let outcome = Self.persona.outcome {
                    RetirementGoalResultScreen(outcome: outcome) { _ in }
                } else {
                    RetirementGoalScreen(model: Self.persona) { _ in }
                }
            }
        }

        /** The board's persona, so Hitung is on and the result is Belum Cocok. */
        @MainActor private static var persona: RetirementGoalModel {
            var values = RetirementGoalValues()
            values.expense = "6.000.000"
            values.age = "28"
            values.retirementAge = "55"
            values.present = "25.000.000"
            values.deposit = "2.000.000"
            values.annualReturn = "10"
            return RetirementGoalModel(values: values)
        }
    }
#endif
