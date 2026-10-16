/**
 Kira Peduli's tools for `ScreenLaunch`, on the canvas's sample: Naskah Pengajuan Keringanan (the
 UI test opens the lender list, 09b, a phrase's sheet and Naskah Disalin, 09c, from the screen),
 Latihan Menenangkan Diri, and Rencana Keselamatanku saved, never saved, failing to save (the test
 taps Simpan Rencana for the failure dialog), or open on its form (PED-10c).
 */
#if DEBUG
    import APIClient
    import Features
    import SwiftUI

    struct CareToolsLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                switch screen {
                case .breathing: BreathingScreen()
                case .safetyPlan: SafetyPlanScreen(service: PreviewCareToolsService())
                case .safetyPlanEmpty: SafetyPlanScreen(service: PreviewCareToolsService(plan: nil))
                case .safetyPlanFailing:
                    SafetyPlanScreen(service: FailingSafetyPlanService(problem: AppProblem(code: "VALIDATION_FAILED")))
                case .safetyPlanForm: SafetyPlanFormLaunch()
                default: NegotiationScriptScreen(service: PreviewCareToolsService()) { _ in }
                }
            }
        }
    }

    /** Isi Rencana Keselamatanku on the board's plan, as its pencil opens it. */
    private struct SafetyPlanFormLaunch: View {
        @State private var form = SafetyPlanFormModel(
            plan: PreviewCareToolsService.samplePlan, focus: .warningSigns, onSave: { _, _ in })

        var body: some View {
            SafetyPlanFormScreen(form: form)
        }
    }
#endif
