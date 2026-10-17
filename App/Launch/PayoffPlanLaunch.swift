/**
 Rencanaku and Perayaan Lunas for `ScreenLaunch`, on the PelunasanAktif board's sample: the plan
 (the UI test taps Tandai Sudah Bayar for the celebration), the plan before one is made, a payment
 that fails (the test taps Tandai Sudah Bayar for the failure dialog), and the celebration itself,
 with an account to go on to or after the last one.
 */
#if DEBUG
    import APIClient
    import Domain
    import Features
    import SwiftUI

    struct PayoffPlanLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            switch screen {
            case .myPlanEmpty: plan(PreviewPayoffPlanService(plan: nil))
            case .myPlanFailing:
                plan(PreviewPayoffPlanService(failing: AppProblem(code: ProblemCode.payoffPaymentTooHigh.rawValue)))
            case .payoffCelebration: celebration(.sampleSettled)
            case .payoffCelebrationLast: celebration(Self.lastPayment)
            default: plan(PreviewPayoffPlanService())
            }
        }

        private func plan(_ service: PreviewPayoffPlanService) -> some View {
            NavigationStack { PayoffPlanScreen(service: service) { _ in } }
        }

        private func celebration(_ payment: DebtPayment) -> some View {
            PayoffCelebration(paid: PaidOffAccount(payment: payment, plan: .sample, name: "Paylater A")) { _ in }
        }

        /** The board's payment with no account left in the plan: Lihat Kira Score. */
        private static let lastPayment = DebtPayment(
            debtId: "paylater-a", monthlyInstalment: 210_000, paidOff: true, nextAccount: nil,
            scoreEstimate: ScoreEstimate(before: 66, after: 71)
        )
    }
#endif
