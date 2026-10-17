/**
 Pendidikan Anak for `ScreenLaunch`, on the board's Raka (3, SD / MI to S1 / D4, Rp15.000.000,00,
 Rp20.000.000,00 collected, Rp2.000.000,00 a month at 8%): the form filled in, Atur Jenjang on SD / MI,
 and Hasil Simulasi (Belum Cocok, Naikkan Investasi to Rp3.300.000,00).
 */
#if DEBUG
    import Domain
    import Features
    import SwiftUI

    struct EducationGoalLaunch: View {
        let screen: LaunchScreen
        @State private var model = EducationGoalLaunch.raka()

        var body: some View {
            NavigationStack {
                switch screen {
                case .educationGoalResult:
                    if let outcome = model.outcome { EducationGoalResultScreen(outcome: outcome) { _ in } }
                case .educationGoalStage:
                    EducationStageScreen(stage: .primary, values: model.values(for: .primary)) { _ in }
                default: EducationGoalScreen(model: model) { _ in }
                }
            }
        }

        @MainActor private static func raka() -> EducationGoalModel {
            let model = EducationGoalModel()
            model.childName = "Raka"
            model.childAge = "3"
            model.income = "15.000.000"
            model.present = "20.000.000"
            model.deposit = "2.000.000"
            model.annualReturn = "8"
            return model
        }
    }
#endif
